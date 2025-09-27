// lib/profile/profile_page.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/profile/change_password_page.dart';
import 'package:untitled/profile/edit_profile_page.dart';
import 'package:untitled/start/start_page.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보를 불러오는 데 실패했습니다: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const StartPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
    }
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _PasswordConfirmDialog();
      },
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    ).then((_) => _loadUserData());
  }

  void _changePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  // --- 👇 재학생 인증 팝업을 띄우는 함수 ---
  void _verifyStudent(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _StudentVerificationDialog(),
    ).then((_) => _loadUserData()); // 팝업이 닫힌 후 사용자 정보 새로고침
  }

  @override
  Widget build(BuildContext context) {
    // isVerified 필드를 확인하여 인증 상태 텍스트를 결정합니다.
    final bool isVerified = _userData?['isVerified'] ?? false;
    final verificationStatusText = isVerified ? '인증 완료' : '미인증';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        title: Text('내 정보', style: mediumBlack16),
        titleSpacing: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userData == null
                ? const Text('사용자 정보를 불러올 수 없습니다.')
                : Row(
              children: [
                Icon(Icons.account_circle,
                    size: 60.w, color: Colors.grey[400]),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData!['nickname'] ?? '닉네임 없음',
                      style: boldBlack18,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_userData!['enrollYear'] ?? ''}학번 | ${_userData!['department'] ?? '학과 정보 없음'}',
                      style: mediumGrey14,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text('사용자 정보 수정', style: mediumBlack16),
            onTap: () => _editProfile(context),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text('비밀번호 변경', style: mediumBlack16),
            onTap: () => _changePassword(context),
          ),
          ListTile(
            leading: Icon(Icons.verified_user_outlined,
                color: isVerified ? Colors.blue : Colors.grey),
            title: Text('재학생 인증', style: mediumBlack16),
            // --- 👇 인증 상태에 따라 다른 텍스트를 보여줍니다. ---
            trailing: Text(
              verificationStatusText,
              style: TextStyle(color: isVerified ? Colors.blue : Colors.grey),
            ),
            onTap: () => _verifyStudent(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('로그아웃', style: mediumBlack16),
            onTap: () => _signOut(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text('계정 탈퇴',
                style: mediumBlack16.copyWith(color: Colors.red)),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}

// --- 👇 재학생 인증 팝업을 위한 새로운 위젯 ---
class _StudentVerificationDialog extends StatefulWidget {
  const _StudentVerificationDialog();

  @override
  State<_StudentVerificationDialog> createState() =>
      _StudentVerificationDialogState();
}

class _StudentVerificationDialogState
    extends State<_StudentVerificationDialog> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 가져오는 데 실패했습니다: $e')),
      );
    }
  }

  Future<void> _uploadVerificationImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 이미지를 첨부해주세요.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 정보 없음');

      // 1. Firebase Storage에 이미지 업로드
      final ref = FirebaseStorage.instance
          .ref()
          .child('student_verification_images')
          .child('${user.uid}.jpg');
      await ref.putFile(_imageFile!);
      final downloadUrl = await ref.getDownloadURL();

      // 2. Firestore에 이미지 URL과 인증 상태, 역할 업데이트 (수정된 부분)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'studentIdImageUrl': downloadUrl,
        'isVerified': false, // 관리자 승인을 위해 false로 설정
        'role': '인증 대기자', // 역할을 '인증 대기자'로 명시적으로 변경
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('인증 이미지가 성공적으로 제출되었습니다. 관리자 승인 후 적용됩니다.')),
      );
      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드에 실패했습니다: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('재학생 인증'),
      backgroundColor: white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 200,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: _imageFile != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_imageFile!, fit: BoxFit.contain),
            )
                : const Center(child: Text('이미지를 첨부해주세요.')),
          ),
          const SizedBox(height: 16),
          Text(
            '재학생 신분 인증 가능한 것들을 첨부해주세요.',
            textAlign: TextAlign.center,
            style: mediumGrey14,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: grey_button_greyBG,
            ),
            icon: Icon(Icons.photo_library_outlined, color: black),
            label: Text('이미지 첨부', style: mediumBlack14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: Text('취소', style: mediumBlack14),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadVerificationImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: black
          ),
          child: _isUploading
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : Text('업로드', style: mediumWhite14),
        ),
      ],
    );
  }
}

// _PasswordConfirmDialog 위젯은 이전과 동일하게 유지
class _PasswordConfirmDialog extends StatefulWidget {
  @override
  __PasswordConfirmDialogState createState() => __PasswordConfirmDialogState();
}

class __PasswordConfirmDialogState extends State<_PasswordConfirmDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleDeleteAccount() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = '비밀번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception("로그인 정보를 찾을 수 없습니다.");
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const StartPage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setState(() {
          _errorMessage = '비밀번호가 올바르지 않습니다.';
        });
      } else {
        setState(() {
          _errorMessage = '오류가 발생했습니다: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '알 수 없는 오류가 발생했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('계정 탈퇴'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('계정을 삭제하시려면 비밀번호를 다시 입력해주세요. 이 작업은 되돌릴 수 없습니다.'),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '비밀번호',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _handleDeleteAccount(),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        _isLoading
            ? const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
        )
            : TextButton(
          onPressed: _handleDeleteAccount,
          child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
