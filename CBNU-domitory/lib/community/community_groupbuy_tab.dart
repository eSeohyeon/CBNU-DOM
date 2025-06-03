import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';


// 공동구매 게시판 탭
class GroupBuyPostTab extends StatefulWidget {
  const GroupBuyPostTab({super.key});

  @override
  State<GroupBuyPostTab> createState() => _GroupBuyPostTabState();
}

class _GroupBuyPostTabState extends State<GroupBuyPostTab> {
  final List<GroupBuyPost> _groupBuyPosts = [];
  final ScrollController _scrollController = ScrollController();
  final GroupBuyPost _groupBuyPost1 = GroupBuyPost(basePost: Post(title: '싱싱한 국내산 흙당근 제주구좌당근 2kg', writer: '멋진농부', date: '2025/05/11', time: '20:59', contents: '당근 같이 먹을 사람~', likeCount: 2), itemUrl: 'https://item.gmarket.co.kr/Item?goodscode=3293466711&buyboxtype=ad', itemImagePath: 'assets/img_item.png', itemPrice: 11130, maxParticipants: 4, currentParticipants: 3);
  bool _isLoading = false;
  bool _hasMore = false;


  @override
  void initState() {
    super.initState();

    for(int i=0; i<50; i++){
      _groupBuyPosts.add(_groupBuyPost1);
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
        children: [Container(
          color: white,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: _groupBuyPosts.length+1,
            itemBuilder: (context, index){
              if(index == _groupBuyPosts.length){
                return _isLoading
                    ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator())) : const SizedBox.shrink();}
              final post = _groupBuyPosts[index];
              return GroupBuyPostItem(post: post);
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

class GroupBuyPostItem extends StatelessWidget {
  final GroupBuyPost post;
  const GroupBuyPostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 16.h),
        child: Row(
            children: [
              Container(
                  width: 100.w,
                  height: 100.w,
                  child: Image.asset(post.itemImagePath, fit: BoxFit.cover)
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.basePost.title, style: mediumBlack14, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                      Text('${post.itemPrice}원', style: boldBlack16),
                      Text('1인당 ${post.itemPrice / post.maxParticipants}원', style: mediumGrey13),
                      SizedBox(height: 20.h),
                      Row(
                          children: [
                            Icon(Icons.person, color: grey_8, size: 20),
                            SizedBox(width: 2.w),
                            Text('${post.currentParticipants}/${post.maxParticipants}', style: mediumGrey13)
                          ]
                      )
                    ]
                ),
              )
            ]
        )
    );
  }
}