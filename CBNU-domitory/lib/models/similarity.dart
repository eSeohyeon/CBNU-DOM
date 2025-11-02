class Similarity {
  final double score; // 전체 점수
  final List<String> top_features; // 상위 항목들
  final Map<String, double> similarity_scores; // 각 항목별 유사도

  Similarity({
    required this.score,
    required this.top_features,
    required this.similarity_scores,
  });
}
