import 'package:flutter/material.dart';
import 'package:Vibes/model/VideoModel.dart';

class RecentlyDownloadedTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const RecentlyDownloadedTile({
    required this.video,
    required this.onTap,
    super.key,
  });

  String _formatDownloadDate(DateTime? downloadDate) {
    if (downloadDate == null) return '날짜 정보 없음';
    
    try {
      final now = DateTime.now();
      final difference = now.difference(downloadDate);
      
      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}개월 전';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}일 전';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}시간 전';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}분 전';
      } else {
        return '방금 전';
      }
    } catch (e) {
      print('Error formatting date: $e');
      return '날짜 오류';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 및 다운로드 배지
            SizedBox(
              height: 90,
              child: Stack(
                children: [
                  // 썸네일
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: video.thumbnailUrls != null && video.thumbnailUrls!.isNotEmpty
                          ? Image.network(
                              video.thumbnailUrls!.first,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[200]!,
                                        Colors.grey[300]!,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.grey[600]!,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[300]!,
                                        Colors.grey[400]!,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.music_note,
                                        color: Colors.grey[600],
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '오프라인',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[400]!,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.music_note,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  
                  // 다운로드 배지
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green[600]!,
                            Colors.green[700]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download_done,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            '다운로드됨',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 재생 시간
                  if (video.duration != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          video.duration!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            SizedBox(height: 8),
            
            // 텍스트 영역
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    video.title ?? 'Unknown Title',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      letterSpacing: -0.2,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  // 다운로드 날짜
                  Row(
                    children: [
                      Icon(
                        Icons.offline_pin,
                        size: 12,
                        color: Colors.green[600],
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDownloadDate(video.downloadDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}