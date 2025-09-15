import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class Attachment {
  final String name;
  final String url;

  Attachment({required this.name, required this.url});
}

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
  List<Attachment> _attachments = [];

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

  Future<void> requestNotificationPermission() async {
    if(await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _fetchDetail() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final element = document.querySelector('#contentBody > div.containerIn > div'); // 본문 내용
        final content = fixImageUrl(element?.outerHtml ?? '<p>내용을 불러올 수 없습니다.</p>'); // 본문 content

        final tableRows = document.querySelectorAll('table.board_insert tr');
        dom.Element? attachmentTd;
        for(var row in tableRows){
          if(row.querySelector('th.gray.brd_none')?.text.trim()=='첨부') {
            attachmentTd = row.querySelector('td.txt_left.brd_none2');
            break;
          }
        }

        if (attachmentTd != null) {
          final fileDivs = attachmentTd.querySelectorAll('div.clearfix');
          for (var fileDiv in fileDivs) {
            final fileName = fileDiv.querySelector('a')?.text.trim();
            final downloadLink = fileDiv.querySelector('a')?.attributes['href'];

            if (fileName != null && downloadLink != null) {
              final baseUri = Uri.parse(widget.url);
              final fullDownloadUrl = baseUri.resolve(downloadLink).toString();

              _attachments.add(Attachment(name: fileName, url: fullDownloadUrl));
            }
          }
        }

        setState(() {
          _title = widget.item.title;
          _writer = widget.item.writer;
          _date = widget.item.date;
          _content = content;
          _loading = false;

          print(_attachments);
        });
      }
    } catch (e) {
      setState(() {
        print('Error : $e');
        _content = '<p>에러 발생: ${e.toString()}</p>';
        _loading = false;
      });
    }
  }

  Widget _buildAttachmentList() {
    if(_attachments.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _attachments.map((attachment) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            children: [
              Icon(Icons.attach_file_rounded, color: black, size: 16),
              SizedBox(width: 2.w),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _downloadFile(attachment.url, attachment.name);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                    child: Text(
                      attachment.name,
                      style: mediumGrey13.copyWith(decoration: TextDecoration.underline),
                      overflow: TextOverflow.ellipsis
                    ),
                  ),
                )
              )
            ]
          )
        );
      }).toList()
    );
  }

  Future<void> _downloadFile(String url, String fileName) async {
    print(url);

    Directory? downloadsDir;

    requestNotificationPermission();

    if(Platform.isAndroid) {
      downloadsDir = Directory("/storage/emulated/0/Download");
    } else if(Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: downloadsDir!.path,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: true,
    );
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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: black, size: 22),
            onPressed: () {
              if (widget.url.isNotEmpty) {
                launchUrl(Uri.parse(widget.url));
              }
            },
          )
        ]
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_title, style: mediumBlack16, textAlign: TextAlign.left),
                        SizedBox(height: 4.h),
                        Text('$_writer | $_date', style: mediumGrey14, textAlign: TextAlign.left),
                        SizedBox(height: 12.h),
                        _buildAttachmentList(),
                      ],
                    ),
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