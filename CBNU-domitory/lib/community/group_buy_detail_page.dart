import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupBuyPostDetailPage extends StatefulWidget {
  final GroupBuyPost post;
  GroupBuyPostDetailPage({super.key, required this.post});

  @override
  State<GroupBuyPostDetailPage> createState() => _GroupBuyPostDetailPageState();
}

class _GroupBuyPostDetailPageState extends State<GroupBuyPostDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
          backgroundColor: white,
          surfaceTintColor: white,
          title: Text('공동구매 게시판', style: boldBlack16),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(Icons.more_vert_rounded, color: black, size: 24),
                onPressed: () {
                  print('more button clicked!');
                }
            )
          ]
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                          width: 36.w,
                          height: 36.w,
                          child: Image.asset('assets/profile_man.png')
                      ),
                      SizedBox(width: 6.w),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.post.basePost.writer, style: boldBlack14),
                            Text('${widget.post.basePost.date} ${widget.post.basePost.time}', style: mediumGrey13)
                          ]
                      )
                    ]
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 160.w,
                    height: 160.h,
                    child: Image.asset(widget.post.itemImagePath, fit: BoxFit.cover),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.post.basePost.title, style: mediumBlack16),
                          Text('${NumberFormat('#,###').format(widget.post.itemPrice)}원', style: boldBlack18),
                          Text('1인당 ${NumberFormat('#,###').format(widget.post.itemPrice~/widget.post.currentParticipants)}원', style: mediumGrey14)
                        ]
                      ),
                      Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(color: grey_seperating_line, borderRadius: BorderRadius.circular(15)),
                        child: IconButton(
                          icon: Icon(Icons.open_in_new_rounded, color: black, size: 24),
                          onPressed: ()  {
                            launchUrl(Uri.parse(widget.post.itemUrl));
                          },
                        )
                      )
                    ]
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Icon(Icons.person, color: grey, size: 20),
                      SizedBox(width: 4.w),
                      Text('${widget.post.currentParticipants}/${widget.post.maxParticipants}', style: mediumGrey14),
                    ]
                  )
                ]
              )
            ),
            Container(
                width: double.infinity,
                height: 1.h,
                color: grey_seperating_line
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(widget.post.basePost.contents, style: mediumBlack14)
            ),
            SizedBox(height: 80.h)
          ]
        )
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            child: SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                child: Text("공동구매 참여하기", style: mediumWhite16),
                onPressed: () {
                  print('참여 버튼 클릭');
                },
                style: ElevatedButton.styleFrom(backgroundColor: black, padding: EdgeInsets.only(top: 6.h, bottom: 6.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), elevation: 2,),
              ),
            )
        ),
      )
    );
  }
}
