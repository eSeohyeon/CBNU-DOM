import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    // 페이지가 시작될 때 사용자 데이터를 불러옵니다.
    _loadUserData();
  }

  // --- Firestore에서 사용자 정보를 가져오는 함수 ---
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
        });
      }
    } catch (e) {
      // 에러 처리
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
    ).then((_) => _loadUserData()); // 수정 페이지에서 돌아왔을 때 정보를 새로고침
  }

  void _changePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('아직 구현되지 않은 기능입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        title: Text('내 정보', style: boldBlack18),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // --- 사용자 정보 표시 UI ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userData == null
                ? const Text('사용자 정보를 불러올 수 없습니다.')
                : Row(
              children: [
                Icon(Icons.account_circle, size: 60.w, color: Colors.grey[400]),
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
            leading: const Icon(Icons.verified_user_outlined),
            title: Text('재학생 인증', style: mediumBlack16),
            onTap: () => _showNotImplemented(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('로그아웃', style: mediumBlack16),
            onTap: () => _signOut(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text('계정 탈퇴', style: mediumBlack16.copyWith(color: Colors.red)),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}

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
      setState(() { _errorMessage = '비밀번호를 입력해주세요.'; });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

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
        setState(() { _errorMessage = '비밀번호가 올바르지 않습니다.'; });
      } else {
        setState(() { _errorMessage = '오류가 발생했습니다: ${e.message}'; });
      }
    } catch (e) {
      setState(() { _errorMessage = '알 수 없는 오류가 발생했습니다.'; });
    } finally {
      if(mounted){
        setState(() { _isLoading = false; });
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
