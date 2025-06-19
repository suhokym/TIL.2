import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

// 사용자 모델 예시
class User {
  final String username;
  final String email;
  final String? profileImage;

  User({required this.username, required this.email, this.profileImage});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
    );
  }
}

// Dio 인스턴스 전역 설정
final dio = Dio();
PersistCookieJar? cookieJar;

Future<void> setupDio() async {
  if (!kIsWeb) {
    final directory = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage("${directory.path}/cookies"),
    );
    dio.interceptors.add(CookieManager(cookieJar!));
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _readingMode = true;
  bool _autoSync = true;
  bool _socialSharing = false;

  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _initializeDioAndFetchUser();
  }

  Future<void> _initializeDioAndFetchUser() async {
    await setupDio();
    setState(() {
      _userFuture = fetchCurrentUser();
    });
  }

  // 세션 기반 현재 사용자 정보 가져오기 (dio 사용)
  Future<User> fetchCurrentUser() async {
    try {
      final response = await dio.get(
        'http://localhost:8080/api/auth/me',
        options: Options(
          extra: kIsWeb ? {'withCredentials': true} : {},
        ),
      );
      // dio는 이미 json decode됨
      return User.fromJson(response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data));
    } on DioException catch (e) {
      throw Exception('사용자 정보를 불러올 수 없습니다: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '설정',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 프로필 섹션 (FutureBuilder로 유저 정보 표시)
            FutureBuilder<User>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      '사용자 정보를 불러올 수 없습니다.\n${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : const AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 24),

            // 이하 기존 설정 항목 유지
            _buildSectionTitle('개인설정'),
            _buildSettingItem('언어', '한국어', () {}),
            _buildSwitchItem('다크 모드', _darkMode, (value) {
              setState(() => _darkMode = value);
            }),
            _buildSwitchItem('읽기 모드', _readingMode, (value) {
              setState(() => _readingMode = value);
            }),
            const SizedBox(height: 24),
            _buildSectionTitle('접근성'),
            _buildSettingItem('폰트 크기', '보통', () {}),
            _buildSettingItem('읽기 모드', '밝기', () {}),
            const SizedBox(height: 24),
            _buildSectionTitle('동기화'),
            _buildSwitchItem('자동 동기화', _autoSync, (value) {
              setState(() => _autoSync = value);
            }),
            _buildSettingItem('동기화 주기', '매일', () {}),
            const SizedBox(height: 24),
            _buildSectionTitle('소셜 공유'),
            _buildSwitchItem('트로피 공유', _socialSharing, (value) {
              setState(() => _socialSharing = value);
            }),
            const SizedBox(height: 24),
            _buildSectionTitle('앱 정보'),
            _buildSettingItem('앱 버전', '1.2.0', () {}),
            _buildSettingItem('개인정보처리방침', '', () {}),
            _buildSettingItem('서비스 약관', '', () {}),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }
}
