import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:untitled/models/chat_message.dart';

class ChatListItem extends StatelessWidget {
  final ChatItem chatItem;
  const ChatListItem({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MM/dd').format(chatItem.latestTimestamp);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: white,
            child: Image.asset('assets/profile_art.png')
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(chatItem.senderId, style: boldBlack16),
                    Text(formattedDate, style: mediumGrey13)
                  ]
                ),
                SizedBox(height: 2.h),
                Text(chatItem.latestContent, style: mediumBlack14)
              ]
            ),
          )
        ]
      )
    );
  }
}
