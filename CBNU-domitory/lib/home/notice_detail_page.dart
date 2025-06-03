import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';


class NoticeDetailPage extends StatefulWidget {
  final String url;
  final item;
  const NoticeDetailPage({super.key, required this.url, required this.item});

  @override
  State<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  String _title = '';
  String _writer = '';
  String _date = '';
  String? _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  String fixImageUrl(String html){ // 공지내용에 이미지 링크 절대경로로 수정
    return html.replaceAllMapped(
      RegExp(r'src="(/[^"]+)"'),
          (match) => 'src="https://dorm.chungbuk.ac.kr${match.group(1)}"',
    );
  }

  Future<void> _fetchDetail() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final element = document.querySelector('#contentBody > div.containerIn > div');

        final content = fixImageUrl(element?.outerHtml ?? '<p>내용을 불러올 수 없습니다.</p>');

        setState(() {
          _title = widget.item.title;
          _writer = widget.item.writer;
          _date = widget.item.date;
          _content = content;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _content = '<p>에러 발생: ${e.toString()}</p>';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
          padding: const EdgeInsets.all(16.0),
          child: HtmlWidget(_content!, textStyle: const TextStyle(fontSize: 14))
      ),
    );
  }
}