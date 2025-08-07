import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';


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
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: black, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_title, style: mediumBlack16),
                      SizedBox(height: 8.h),
                      Text('$_writer | $_date', style: mediumGrey14)
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                    width: double.infinity,
                    height: 1.h,
                    color: grey_seperating_line
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 24.h),
                      child: HtmlWidget(_content!, textStyle: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}