import 'package:untitled/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:untitled/home/notice_detail_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/notice.dart';
import 'package:untitled/themes/styles.dart';

class NoticeListPage extends StatefulWidget {
  const NoticeListPage({super.key});

  @override
  State<NoticeListPage> createState() => _NoticeListPageState();
}

class _NoticeListPageState extends State<NoticeListPage> {
  final List<Notice> _notices = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool exclude_pinned = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNotices();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchNotices();
      }
    });
  }

  Future<void> _fetchNotices() async {
    setState(() => _isLoading = true);
    final url = Uri.parse(
        'https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20039&mod=&page=$_currentPage&scode=00000002&listCnt=20');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final rows = document.querySelectorAll('#contentBody > form > div.containerIn > table > tbody > tr');

        if (rows.isEmpty) {
          _hasMore = false;
        }

        for (var row in rows) {
          final is_pinned = row.classes.contains('brd_notice'); // 고정 공지 UI에서 분리해야함.
          if (exclude_pinned && is_pinned) continue;

          final cells = row.querySelectorAll('td');
          if (cells.length >= 4) {
            final titleAnchor = cells[1].querySelector('a');
            final title = titleAnchor?.text.trim() ?? '';
            final writer = cells[2].text.trim();
            final date = cells[3].text.trim();
            final href = titleAnchor?.attributes['href'] ?? '';
            final link =
                'https://dorm.chungbuk.ac.kr/home/$href';

            _notices.add(Notice(
              title: title,
              writer: writer,
              date: date,
              link: link,
            ));
          }
        }
        _currentPage++;
        exclude_pinned = true;
      }
    } catch (e) {
      debugPrint("Failed to get data: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        title: Text('공지사항', style: mediumBlack16),
        titleSpacing: 0,
      ),
      body: ListView.separated(
        controller: _scrollController,
        itemCount: _notices.length + 1,
        separatorBuilder: (context, index) => Divider(height: 1, color: grey_seperating_line),
        itemBuilder: (context, index) {
          if (index == _notices.length) {
            return _isLoading
                ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()))
                : const SizedBox.shrink();
          }
          final notice = _notices[index];
          return ListTile(
            title: Text(notice.title),
            subtitle: Text('${notice.writer} | ${notice.date}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoticeDetailPage(url: notice.link, item: notice),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

