import 'package:flutter/material.dart';
import 'package:Vibes/model/VideoModel.dart';
import 'package:Vibes/services/PlayListState.dart';
import 'package:Vibes/services/FileServices.dart';

class RecentlyDownloadedState extends ChangeNotifier {
  final PlayListState _playListState;
  List<VideoModel> _recentlyDownloaded = [];
  bool _isLoading = true; // Start with loading state

  RecentlyDownloadedState(this._playListState) {
    // Listen to playlist changes to update recently downloaded list
    _playListState.addListener(_onPlaylistChanged);
    // Delay initial load to ensure PlayListState is properly initialized
    Future.delayed(Duration(milliseconds: 500), () {
      _loadRecentlyDownloaded();
    });
  }

  // Getter for recently downloaded videos
  List<VideoModel> get recentlyDownloaded => _recentlyDownloaded;
  bool get isLoading => _isLoading;

  // Load recently downloaded videos from playlist
  Future<void> _loadRecentlyDownloaded() async {
    print('[RecentlyDownloadedState] Starting to load recently downloaded...');
    _isLoading = true;
    notifyListeners();

    try {
      // Get all videos from playlist that have audio files downloaded
      final List<VideoModel> validDownloads = [];
      final List<VideoModel> invalidVideos = [];
      
      print('[RecentlyDownloadedState] Playlist size: ${_playListState.playlist.length}');
      
      for (VideoModel video in _playListState.playlist) {
        // Skip if video or videoId is null
        if (video.videoId == null || video.videoId!.isEmpty) {
          continue;
        }

        // Check if video has audio path and file exists
        if (video.audioPath != null && video.audioPath!.isNotEmpty) {
          try {
            bool fileExists = await FileServices.instance.isVideoDownloaded(videoId: video.videoId!);
            if (fileExists) {
              // If downloadDate is null, try to get file creation date as fallback
              if (video.downloadDate == null) {
                DateTime? fileCreationDate = await FileServices.instance.getFileCreationDate(videoId: video.videoId!);
                video.downloadDate = fileCreationDate ?? DateTime.now().subtract(Duration(days: 30)); // Use file date or fallback
                print('[RecentlyDownloadedState] Setting fallback date for: ${video.title} - Date: ${video.downloadDate}');
                // Update Hive database with the fallback date
                await _playListState.updateVideoModel(video);
              }
              validDownloads.add(video);
              print('[RecentlyDownloadedState] Valid download found: ${video.title}');
            } else {
              // File doesn't exist but audioPath is set - mark for cleanup
              invalidVideos.add(video);
            }
          } catch (e) {
            print('[RecentlyDownloadedState] Error checking file for ${video.videoId}: $e');
            // On error, assume file doesn't exist
            invalidVideos.add(video);
          }
        }
      }

      // Clean up invalid videos (remove audioPath from videos where file doesn't exist)
      _cleanupInvalidDownloads(invalidVideos);

      // Sort by download date (newest first), fallback to order if no download date
      validDownloads.sort((a, b) {
        if (a.downloadDate != null && b.downloadDate != null) {
          return b.downloadDate!.compareTo(a.downloadDate!);
        } else if (a.downloadDate != null) {
          return -1; // a comes first
        } else if (b.downloadDate != null) {
          return 1; // b comes first
        } else {
          return 0; // maintain current order
        }
      });

      // Take only the most recent 10 downloads
      _recentlyDownloaded = validDownloads.take(10).toList();
      print('[RecentlyDownloadedState] Found ${_recentlyDownloaded.length} recently downloaded videos');
    } catch (e) {
      print('[RecentlyDownloadedState] Error loading recently downloaded: $e');
      _recentlyDownloaded = [];
    } finally {
      _isLoading = false;
      print('[RecentlyDownloadedState] Loading completed. isLoading: $_isLoading');
      notifyListeners();
    }
  }

  // Clean up invalid downloads by setting audioPath to null
  void _cleanupInvalidDownloads(List<VideoModel> invalidVideos) {
    if (invalidVideos.isEmpty) return;

    try {
      // This would require updating the Hive database
      // For now, just log the cleanup - a full implementation would update the database
      print('Found ${invalidVideos.length} videos with missing files - cleanup required');
      
      // TODO: Implement database cleanup when missing files are detected
      // This would involve updating the VideoModel in Hive to set audioPath = null
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  // Called when playlist changes
  void _onPlaylistChanged() {
    _loadRecentlyDownloaded();
  }

  // Refresh the recently downloaded list
  Future<void> refresh() async {
    await _loadRecentlyDownloaded();
  }

  @override
  void dispose() {
    _playListState.removeListener(_onPlaylistChanged);
    super.dispose();
  }
}