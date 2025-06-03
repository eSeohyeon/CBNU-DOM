import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:untitled/models/meal.dart';

enum DormType{
  BONGUAN(name: "본관", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=1"),
  SEONGJAE(name: "양성재", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=2"),
  JINJAE(name: "양진재", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=3");

  final String name;
  final String url;
  const DormType({required this.name, required this.url});
}

class MealDetailPage extends StatefulWidget {
  const MealDetailPage({Key? key}) : super(key: key);

  @override
  State<MealDetailPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealDetailPage> {
  DormType _selectedDorm = DormType.BONGUAN;
  final List<Meal> _meals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  Future<void> fetchMeals() async {
    setState(() {
      _isLoading = true;
    });

    final url = _selectedDorm.url;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('식단 데이터 불러오기 실패'); // 이런 거 뜨면 새로고침할 수 있게 해야함 (버튼이나 스크롤)
    }

    final document = parser.parse(response.body);
    final tbody = document.querySelector('#contentBody > table.contTable_c.m_table_c.margin_t_30 > tbody');

    if (tbody == null) {
      throw Exception('식단 데이터 없음');
    }

    final rows = tbody.querySelectorAll('tr');
    _meals.clear();

    for (var row in rows) {
      final cells = row.querySelectorAll('td');
      if (cells.length < 4) continue;

      final dateAndDay = cells[0].text.trim().split('\n');
      final date = dateAndDay[0].trim();
      final dayOfWeek = dateAndDay.length > 1 ? dateAndDay[1].trim() : '';

      final breakfast = cells[1].innerHtml.replaceAll('<br>', '\n').trim();
      final lunch = cells[2].innerHtml.replaceAll('<br>', '\n').trim();
      final dinner = cells[3].innerHtml.replaceAll('<br>', '\n').trim();

      _meals.add(Meal(
        date: date,
        dayOfWeek: dayOfWeek,
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void onDormTypeSelected(DormType type) {
    if (_selectedDorm != type) {
      setState(() {
        _selectedDorm = type;
      });
      fetchMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기숙사 식단'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DormButton(
                title: '본관',
                isSelected: _selectedDorm == DormType.BONGUAN,
                onTap: () => onDormTypeSelected(DormType.BONGUAN),
              ),
              DormButton(
                title: '양성재',
                isSelected: _selectedDorm == DormType.SEONGJAE,
                onTap: () => onDormTypeSelected(DormType.SEONGJAE),
              ),
              DormButton(
                title: '양진재',
                isSelected: _selectedDorm == DormType.JINJAE,
                onTap: () => onDormTypeSelected(DormType.JINJAE),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _meals.length,
              itemBuilder: (context, index) {
                final meal = _meals[index];
                return SizedBox(
                  width: 300,
                  height: 1200,
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(meal.dayOfWeek, style: TextStyle(fontSize: 16)),
                        Text(meal.date, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('아침',  style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
                        Text(meal.breakfast, style: TextStyle(fontSize: 14)),
                        Text('점심',  style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
                        Text(meal.lunch, style: TextStyle(fontSize: 14)),
                        Text('저녁',  style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
                        Text(meal.dinner, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class DormButton extends StatelessWidget { // 그냥 버튼 ui용 기능이랑 관계 없음
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const DormButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey,
        ),
        onPressed: onTap,
        child: Text(title),
      ),
    );
  }
}