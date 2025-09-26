import 'package:group_button/group_button.dart';

class GroupCategory {
  final String categoryName; // 예: '생활 패턴', '생활 습관', 'MBTI'
  final List<GroupData> groups;

  GroupCategory(this.categoryName, this.groups);
}

class GroupData {
  final String title;
  final List<String> options;
  final GroupButtonController controller;

  GroupData({required this.title, required this.options}) : controller = GroupButtonController();
}

final List<GroupCategory> allCategories = [

  GroupCategory('기본정보', [
    GroupData(title: '생활관', options: ['정의관', '진리관', '개척관', '계영원', '명덕관', '신민관', '지선관', '인의관', '예지관', '양현재(남)', '양현재(여)']),
    GroupData(title: '단과대', options: ['인문대', '사과대', '자과대', '경영대', '공과대', '전정대', '농생대', '생과대', '수의대', '의과대', '약학대', '자율전공', '융합전공']),
  ]),

  GroupCategory('생활패턴', [
    GroupData(title: '기상시간', options: ['4시', '5시', '6시', '7시', '8시', '9시', '10시']),
    GroupData(title: '취침시간', options: ['9시', '10시', '11시', '자정', '1시', '2시', '3시']),
    GroupData(title: '샤워시각', options: ['아침샤워', '저녁샤워']),
    GroupData(title: '본가주기', options: ['매주', '2주이상']),
  ]),

  GroupCategory('생활습관', [
    GroupData(title: '흡연여부', options: ['흡연', '비흡연']),
    GroupData(title: '잠버릇', options: ['없음', '있음']),
    GroupData(title: '청소', options: ['수시로', '한 번에']),
    GroupData(title: '소리', options: ['이어폰', '스피커']),
  ]),

  GroupCategory('MBTI', [
    GroupData(title: 'EI', options: ['E', 'I']),
    GroupData(title: 'NS', options: ['N', 'S']),
    GroupData(title: 'TF', options: ['T', 'F']),
    GroupData(title: 'PJ', options: ['P', 'J']),
  ]),

  GroupCategory('성향', [
    GroupData(title: '더위', options: ['많이 탐', '적게 탐']),
    GroupData(title: '추위', options: ['많이 탐', '적게 탐 ']),
    GroupData(title: '잠귀', options: ['밝음', '어두움']),
    GroupData(title: '실내통화', options: ['싫어요', '짧게만', '상관 없음']),
    GroupData(title: '실내취식', options: ['싫어요', '과자류만', '상관 없음']),
    GroupData(title: '친구초대', options: ['싫어요', '사전 허락', '상관 없음']),
    GroupData(title: '벌레', options: ['극혐', '못 잡음', '중간', '잡음', '잘 잡음']),
  ]),

  GroupCategory('취미/기타', [
    GroupData(title: '컴퓨터게임', options: ['안 함', '중간', '좋아함']),
    GroupData(title: '운동', options: ['안 함', '중간', '좋아함']),
  ]),
];