import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';


// 자유게시판 탭
class FreePostTab extends StatefulWidget {
  const FreePostTab({super.key});

  @override
  State<FreePostTab> createState() => _FreePostTabState();
}

class _FreePostTabState extends State<FreePostTab> {
  final List<Post> _posts = [];
  final ScrollController _scrollController = ScrollController();
  final Post _post2 = Post(title: '취업 꿀팁', writer: '서울사이버대학', date: '05/09', time: '03:34', contents: '서울사이버대학에 다니고 나의 성공시대 시작됐다.', likeCount: 222);
  //final Post _post2 = Post(title: '사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거같잖아피로하잖아겁에질렸잖아몽롱하잖아고문당하는거같잖아불안하잖아죽을거같잖아고통스럽잖아미칠거같잖아숨이막히잖아', writer: '부족한사람', date: '05/07', time: '12:34', contents: '사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거같잖아피로하잖아겁에질렸잖아몽롱하잖아고문당하는거같잖아불안하잖아죽을거같잖아고통스럽잖아미칠거같잖아숨이막히잖아폐가아프잖아그만해야하잖아정신나갈거같잖아루나틱하잖아토할거같잖아구역질이나올거같잖아속이뒤트는거같잖아비틀어질거같잖아휘청거릴거샅잖아어지럽잖아배사아프잖아위가꼬이는거같잖아장이꼬이는거같잖아온몸에쥐난거같잖아심장이아프잖아다들지쳤잖아사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거', likeCount: 55);
  bool _isLoading = false;
  bool _hasMore = false;


  @override
  void initState() {
    super.initState();

    for(int i=0; i<50; i++){
      _posts.add(_post2);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        print("스크롤 끝에 도달함");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Container(
            color: white,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: _posts.length+1,
              itemBuilder: (context, index){
                if(index == _posts.length){
                  return _isLoading
                      ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator())) : const SizedBox.shrink();}
                final post = _posts[index];
                return FreePostListItem(post: post);
              },
              separatorBuilder: (context, index) => Divider(height: 1, color: grey_seperating_line),
            ),
          ),
          Positioned(
              left: 139.w,
              bottom: 80.h,
              child: ElevatedButton.icon(
                onPressed: () { print('write button clicked'); },
                icon: Icon(Icons.add, color: black, size: 20),
                label: Text('글쓰기', style: mediumBlack16),
                style: ElevatedButton.styleFrom(overlayColor: grey_8, backgroundColor: white, side: BorderSide(color: grey_seperating_line, width: 1.0), padding: EdgeInsets.only(top: 8.h, bottom: 8.h, left: 11.w, right: 14.w), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), elevation: 2, ),
              )
          )
        ]
    );
  }
}

class FreePostListItem extends StatelessWidget {
  final Post post;
  const FreePostListItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 14.h, bottom: 14.h),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: mediumBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left, softWrap: false),
            Text(post.contents, style: mediumBlack14, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left, softWrap: false),
            SizedBox(height: 6.h),
            Row(
                children: [
                  Text(post.time, style: mediumGrey13),
                  SizedBox(width: 10.w),
                  Text('|', style: mediumGrey13),
                  SizedBox(width: 10.w),
                  Text(post.writer, style: mediumGrey13)
                ]
            )
          ]
      ),
    );
  }
}
