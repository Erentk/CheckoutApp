import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const CheckOutApp());
}

class CheckOutApp extends StatelessWidget {
  const CheckOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF1DB954),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- EVDEN ÇIKIŞ MODU LİSTELERİ ---
  final List<CheckTask> _exitDefaultTasks = [
    CheckTask(title: "Pencereler", description: "Tüm odaların pencerelerinin kapalı ve kilitli olduğunu gör."),
    CheckTask(title: "Ocak & Fırın", description: "Ocağın vanasını ve fırının düğmelerini fiziksel olarak dokunarak kontrol et ve kapalı olduğundan emin ol."),
    // 6. MADDE: FİŞLER düzeltmesi
    CheckTask(title: "Ütü & Fişler", description: "Ütünün ve yüksek ısı üreten cihazların fişten çekildiğinden emin ol."),
    CheckTask(title: "Işıklar", description: "Odaların, banyonun ve koridorun ışıklarını son kez kontrol et, açık kalanları söndür."),
    CheckTask(title: "Şarj & Powerbank", description: "Telefonunun şarj aletini veya dolu olduğundan emin olduğun powerbank'ini çantana ya da cebine koy."),
    CheckTask(title: "Cüzdan & Anahtar", description: "Nakit parayı, kartları ve ev anahtarını somut olarak eline al."),
  ];

  final List<CheckTask> _vacationTasks = [
    CheckTask(title: "Ana Su Vanası", description: "Uzun süre evde olmayacaksın, olası sızıntılara karşı ana su vanasını tamamen kapat."),
    CheckTask(title: "Elektrik Sigortaları", description: "Buzdolabı dışındaki tüm odaların ve cihazların sigorta şalterlerini indir."),
  ];

  // 4. MADDE: anahtarla kilitle -> kilitle yapıldı
  final CheckTask _finalExitDoorTask = CheckTask(
    title: "Dış Kapı", 
    description: "Kapıyı çek, kilitle ve kolu elinle yukarı-aşağı kontrol et."
  );

  // --- GECE RUTİNİ MODU LİSTESİ ---
  final List<CheckTask> _nightDefaultTasks = [
    // 7. MADDE: GİRİŞ KAPISI düzeltmesi
    CheckTask(title: "Giriş Kapısı", description: "Dış kapıyı kilitle ve varsa emniyet kelepçesini/zincirini tak."),
    CheckTask(title: "Mutfak Kontrolü", description: "Ocağın kapalı olduğundan emin ol, tezgahta açıkta yiyecek bırakma."),
    // 8. MADDE: ELEKTRONİK CİHAZLAR düzeltmesi
    CheckTask(title: "Elektronik Cihazlar", description: "Televizyon, bilgisayar gibi cihazların stand-by ışıklarını kontrol et, priz anahtarlarını kapat ve fişlerini çek."),
    CheckTask(title: "Telefon & Şarj", description: "Telefonunun sabah alarmını kur. Eğer telefonun şarja takılı ise uyumadan önce prizden çıkar."),
    CheckTask(title: "Son Işıklar", description: "Evdeki tüm gereksiz ışıkların kapalı olduğunu kontrol et."),
  ];

  // --- İŞYERE KAPANISI MODU LİSTELERİ ---
  final List<CheckTask> _workDefaultTasks = [
    // 9. MADDE: ELEKTRONİK & FİŞLER düzeltmesi
    CheckTask(title: "Elektronik & Fişler", description: "Bilgisayarlar, yazıcılar and mutfaktaki cihazlar dahil bütün fişlerin prizden çekili olduğundan emin ol."),
    CheckTask(title: "Yanıcı Maddeler", description: "Ofiste/atölyede tiner, dezenfektan veya yanıcı kimyasal varsa ağzını sıkıca kapat ve güvenli dolaba kaldır."),
    CheckTask(title: "Işıklar", description: "Ofis, depo, lavabo ve vitrin ışıklarını son kez kontrol et, açık kalanları söndür."),
    // 3. MADDE: Anahtarlar & Eşyalar açıklaması tam istendiği gibi güncellendi
    CheckTask(title: "Anahtarlar & Eşyalar", description: "İşyeri anahtarlarını ve kişisel eşyalarını yanına aldığından emin ol."),
    // 10. MADDE: GÜVENLİK ALARMI düzeltmesi
    CheckTask(title: "Güvenlik Alarmı", description: "Alarm şifresini gir ve panelden onay sesini duyarak sistemin kurulduğundan emin ol."),
  ];

  final List<CheckTask> _workLongClosingTasks = [
    CheckTask(title: "İşyeri Su Vanası", description: "Hafta sonu veya tatil dönemi için olası sızıntılara karşı ana su vanasını kapat."),
    CheckTask(title: "İşyeri Sigortaları", description: "Güvenlik kameraları ve buzdolabı dışındaki tüm çalışma alanlarının şalterlerini indir."),
  ];

  // 4. MADDE: anahtarla kilitle -> kilitle yapıldı
  // 11. MADDE: İŞYERİ KAPISI düzeltmesi
  final CheckTask _finalWorkDoorTask = CheckTask(
    title: "İşyeri Kapısı", 
    description: "Dış kapıyı/kepengi çek, kilitle ve fiziksel olarak kilitlendiğini elinle kontrol et."
  );

  List<CheckTask> _customExitTasks = []; 
  List<CheckTask> _customNightTasks = []; 
  List<CheckTask> _customWorkTasks = []; 
  final List<CheckTask> _activeSessionTasks = [];

  int _currentIndex = 0;
  bool _isSessionActive = false;
  bool _isVacationMode = false; 
  bool _isWorkLongCloseMode = false; 
  int _selectedModeIndex = 0; 

  String _lastExitTime = "";
  String _lastExitDate = "";
  String _lastNightTime = "";
  String _lastNightDate = "";
  String _lastWorkTime = ""; 
  String _lastWorkDate = ""; 

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastExitTime = prefs.getString('lastExitTime') ?? "";
      _lastExitDate = prefs.getString('lastExitDate') ?? "";
      _lastNightTime = prefs.getString('lastNightTime') ?? "";
      _lastNightDate = prefs.getString('lastNightDate') ?? "";
      _lastWorkTime = prefs.getString('lastWorkTime') ?? "";
      _lastWorkDate = prefs.getString('lastWorkDate') ?? "";
      
      final String? customExitJson = prefs.getString('customExitTasks');
      if (customExitJson != null) {
        _customExitTasks = (jsonDecode(customExitJson) as List).map((item) => CheckTask(title: item['title'], description: item['description'])).toList();
      }

      final String? customNightJson = prefs.getString('customNightTasks');
      if (customNightJson != null) {
        _customNightTasks = (jsonDecode(customNightJson) as List).map((item) => CheckTask(title: item['title'], description: item['description'])).toList();
      }

      final String? customWorkJson = prefs.getString('customWorkTasks');
      if (customWorkJson != null) {
        _customWorkTasks = (jsonDecode(customWorkJson) as List).map((item) => CheckTask(title: item['title'], description: item['description'])).toList();
      }
    });
  }

  Future<void> _saveCustomTasks() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedModeIndex == 0) {
      final List<Map<String, String>> toSave = _customExitTasks.map((t) => {'title': t.title, 'description': t.description}).toList();
      await prefs.setString('customExitTasks', jsonEncode(toSave));
    } else if (_selectedModeIndex == 1) {
      final List<Map<String, String>> toSave = _customNightTasks.map((t) => {'title': t.title, 'description': t.description}).toList();
      await prefs.setString('customNightTasks', jsonEncode(toSave));
    } else {
      final List<Map<String, String>> toSave = _customWorkTasks.map((t) => {'title': t.title, 'description': t.description}).toList();
      await prefs.setString('customWorkTasks', jsonEncode(toSave));
    }
  }

  void _addCustomTask() {
    if (_titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
      setState(() {
        var newTask = CheckTask(title: _titleController.text, description: _descController.text);
        if (_selectedModeIndex == 0) {
          _customExitTasks.add(newTask);
        } else if (_selectedModeIndex == 1) {
          _customNightTasks.add(newTask);
        } else {
          _customWorkTasks.add(newTask);
        }
      });
      _saveCustomTasks();
      _titleController.clear();
      _descController.clear();
      Navigator.pop(context); 
    }
  }

  void _deleteCustomTask(int index) {
    setState(() {
      if (_selectedModeIndex == 0) {
        _customExitTasks.removeAt(index);
      } else if (_selectedModeIndex == 1) {
        _customNightTasks.removeAt(index);
      } else {
        _customWorkTasks.removeAt(index);
      }
    });
    _saveCustomTasks();
  }

  void _startNewSession() async {
    await NotificationService.cancelNotification();
    _activeSessionTasks.clear();
    
    if (_selectedModeIndex == 0) {
      _activeSessionTasks.addAll(_exitDefaultTasks.map((t) => CheckTask(title: t.title, description: t.description)));
      if (_customExitTasks.isNotEmpty) {
        _activeSessionTasks.addAll(_customExitTasks.map((t) => CheckTask(title: t.title, description: t.description)));
      }
      if (_isVacationMode) {
        _activeSessionTasks.addAll(_vacationTasks.map((t) => CheckTask(title: t.title, description: t.description)));
      }
      _activeSessionTasks.add(CheckTask(title: _finalExitDoorTask.title, description: _finalExitDoorTask.description));
    } else if (_selectedModeIndex == 1) {
      for (int i = 0; i < _nightDefaultTasks.length - 1; i++) {
        _activeSessionTasks.add(CheckTask(title: _nightDefaultTasks[i].title, description: _nightDefaultTasks[i].description));
      }
      if (_customNightTasks.isNotEmpty) {
        _activeSessionTasks.addAll(_customNightTasks.map((t) => CheckTask(title: t.title, description: t.description)));
      }
      _activeSessionTasks.add(CheckTask(title: _nightDefaultTasks.last.title, description: _nightDefaultTasks.last.description));
    } else {
      for (int i = 0; i < _workDefaultTasks.length - 1; i++) {
        _activeSessionTasks.add(CheckTask(title: _workDefaultTasks[i].title, description: _workDefaultTasks[i].description));
      }
      if (_customWorkTasks.isNotEmpty) {
        _activeSessionTasks.addAll(_customWorkTasks.map((t) => CheckTask(title: t.title, description: t.description)));
      }
      if (_isWorkLongCloseMode) {
        _activeSessionTasks.addAll(_workLongClosingTasks.map((t) => CheckTask(title: t.title, description: t.description)));
      }
      _activeSessionTasks.add(CheckTask(title: _workDefaultTasks.last.title, description: _workDefaultTasks.last.description));
      _activeSessionTasks.add(CheckTask(title: _finalWorkDoorTask.title, description: _finalWorkDoorTask.description));
    }

    setState(() {
      _isSessionActive = true;
      _currentIndex = 0;
    });
  }

  Future<void> _completeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    String timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    String dateString = "${now.day} Haz 2026"; 

    if (_selectedModeIndex == 0) {
      await prefs.setString('lastExitTime', timeString);
      await prefs.setString('lastExitDate', dateString);
      await NotificationService.showPersistentNotification(timeString);
      setState(() {
        _lastExitTime = timeString;
        _lastExitDate = dateString;
        _isVacationMode = false; 
      });
    } else if (_selectedModeIndex == 1) {
      await prefs.setString('lastNightTime', timeString);
      await prefs.setString('lastNightDate', dateString);
      setState(() {
        _lastNightTime = timeString;
        _lastNightDate = dateString;
      });
    } else {
      await prefs.setString('lastWorkTime', timeString);
      await prefs.setString('lastWorkDate', dateString);
      setState(() {
        _lastWorkTime = timeString;
        _lastWorkDate = dateString;
        _isWorkLongCloseMode = false;
      });
    }

    setState(() {
      _isSessionActive = false;
      _currentIndex = 0;
    });
  }

  void _handleTaskCheck() {
    HapticFeedback.vibrate();
    if (_currentIndex < _activeSessionTasks.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _completeSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSessionActive 
            ? (_selectedModeIndex == 0 ? "🛡️ Evden Çıkış" : _selectedModeIndex == 1 ? "🌙 Gece Kontrolü" : "🏬 İşyerinden Çıkış")
            : "🛡️ CheckOut"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: _isSessionActive ? _buildActiveSessionUI() : _buildSummaryUI(),
        ),
      ),
    );
  }

  Widget _buildActiveSessionUI() {
    final currentTask = _activeSessionTasks[_currentIndex];
    
    Color uiThemeColor = const Color(0xFF1DB954); 
    if (_selectedModeIndex == 1) uiThemeColor = Colors.indigoAccent;
    if (_selectedModeIndex == 2) uiThemeColor = Colors.amber;

    IconData taskIcon = Icons.check_circle_outline_rounded;
    Color insideIconColor = uiThemeColor;

    if (currentTask.title.contains("Su Vanası")) {
      taskIcon = Icons.water_drop_rounded;
      insideIconColor = Colors.blueAccent; 
    } else if (currentTask.title.contains("Sigorta")) {
      taskIcon = Icons.bolt_rounded;
      insideIconColor = Colors.amber; 
    } else if (currentTask.title == "Yanıcı Maddeler") {
      taskIcon = Icons.local_fire_department_rounded;
      insideIconColor = Colors.redAccent;
    } else if (currentTask.title == "Güvenlik Alarmı") {
      taskIcon = Icons.add_moderator_rounded;
      insideIconColor = Colors.tealAccent;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${_currentIndex + 1} / ${_activeSessionTasks.length}",
          style: TextStyle(color: uiThemeColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: Column(
            children: [
              Icon(taskIcon, size: 48, color: insideIconColor),
              const SizedBox(height: 16),
              Text(
                currentTask.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                currentTask.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[400], height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 75,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: uiThemeColor, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _handleTaskCheck,
            child: const Text(
              "KONTROL ETTİM, EMİNİM",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryUI() {
    bool hasExitHistory = _lastExitTime.isNotEmpty;
    bool hasNightHistory = _lastNightTime.isNotEmpty;
    bool hasWorkHistory = _lastWorkTime.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("Evden Çıkış", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  selected: _selectedModeIndex == 0,
                  selectedColor: const Color(0xFF1DB954),
                  onSelected: (bool selected) { if (selected) setState(() { _selectedModeIndex = 0; }); },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("Gece Rutini", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  selected: _selectedModeIndex == 1,
                  selectedColor: Colors.indigoAccent,
                  onSelected: (bool selected) { if (selected) setState(() { _selectedModeIndex = 1; }); },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("İşyerinden Çıkış", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  selected: _selectedModeIndex == 2,
                  selectedColor: Colors.amber,
                  onSelected: (bool selected) { if (selected) setState(() { _selectedModeIndex = 2; }); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // --- 1. EVDEN ÇIKIŞ PANELİ ---
          if (_selectedModeIndex == 0) ...[
            if (hasExitHistory) ...[
              const Icon(Icons.verified_user_rounded, size: 70, color: Color(0xFF1DB954)),
              const SizedBox(height: 16),
              const Text("İÇİN RAHAT OLSUN", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // 1. MADDE: Evden çıkış sonlanma alt metni güncellendi
              Text("En son $_lastExitDate tarihinde, saat $_lastExitTime civarında evden çıkarken tüm kritik noktaları kontrol ettin. İçin tamamen rahat olsun, her şey yolunda.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[400], height: 1.4)),
            ] else ...[
              const Icon(Icons.gite_rounded, size: 70, color: Color(0xFF1DB954)),
              const SizedBox(height: 16),
              const Text("Güvenli Çıkış", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text("Evden çıkmadan önce şüpheye düşmemek ve gününü huzurlu geçirmek için kontrolü başlatın.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[400], height: 1.4)),
            ],
            const SizedBox(height: 30),
            _buildSwitchTile("Uzun Süreli / Tatil Modu", "Listeye su vanası ve sigorta kontrollerini ekler.", _isVacationMode, (v) => setState(() => _isVacationMode = v), const Color(0xFF1DB954)),
            _buildAddCustomButton(const Color(0xFF1DB954)),
            _buildCustomTasksList(_customExitTasks),
          ],

          // --- 2. GECE RUTİNİ PANELİ ---
          if (_selectedModeIndex == 1) ...[
            if (hasNightHistory) ...[
              const Icon(Icons.bedtime_rounded, size: 70, color: Colors.indigoAccent),
              const SizedBox(height: 16),
              const Text("HUZURLU UYKULAR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // 12. MADDE: Gece rutini sonlanma alt metni güncellendi
              Text("En son $_lastNightDate gecesi, saat $_lastNightTime civarında uyumadan önce tüm güvenlik adımlarını tamamladın. Gözlerini güvenle kapatabilirsin.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[400], height: 1.4)),
            ] else ...[
              const Icon(Icons.nights_stay_outlined, size: 70, color: Colors.indigoAccent),
              const SizedBox(height: 16),
              const Text("Gece Rutini", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text("Yatmadan önce aklında hiçbir soru işareti kalmaması ve derin bir uyku çekmek için gece kontrolünü başlatın.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[400], height: 1.4)),
            ],
            const SizedBox(height: 20),
            _buildAddCustomButton(Colors.indigoAccent),
            _buildCustomTasksList(_customNightTasks),
          ],

          // --- 3. İŞYERİNDEN ÇIKIŞ PANELİ ---
          if (_selectedModeIndex == 2) ...[
            if (hasWorkHistory) ...[
              const Icon(Icons.domain_verification_rounded, size: 70, color: Colors.amber),
              const SizedBox(height: 16),
              // 2. MADDE: İkon üstü yazı İŞYERİN GÜVENDE yapıldı
              const Text("İŞYERİN GÜVENDE", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // 5. MADDE: "onayladın" kelimesi "kontrol ettin" olarak güncellendi
              Text("En son $_lastWorkDate tarihinde, saat $_lastWorkTime civarında işyerini kapatırken kritik tüm noktaları sırayla kontrol ettin. Bereketli kazançlar!", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[400], height: 1.4)),
            ] else ...[
              const Icon(Icons.storefront_rounded, size: 70, color: Colors.amber),
              const SizedBox(height: 16),
              const Text("İşyeri Kapanışı", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text("Dükkandan veya ofisten çıkmadan önce hiçbir risk kalmaması için kontrolü başlatın.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[400], height: 1.4)),
            ],
            const SizedBox(height: 30),
            _buildSwitchTile("Hafta Sonu / Uzun Kapanış", "Listeye işyeri su vanası ve sigorta kontrollerini ekler.", _isWorkLongCloseMode, (v) => setState(() => _isWorkLongCloseMode = v), Colors.amber),
            _buildAddCustomButton(Colors.amber),
            _buildCustomTasksList(_customWorkTasks),
          ],
          
          const SizedBox(height: 35),
          
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _selectedModeIndex == 0 ? const Color(0xFF1DB954) : _selectedModeIndex == 1 ? Colors.indigoAccent : Colors.amber, 
                  width: 2
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _startNewSession,
              child: Text(
                _selectedModeIndex == 0 
                    ? (hasExitHistory ? "YENİDEN EVDEN ÇIK" : "EVDEN ÇIK") 
                    : _selectedModeIndex == 1 
                        ? (hasNightHistory ? "GECE RUTİNİNİ TEKRARLA" : "GECE KONTROLÜNÜ BAŞLAT")
                        : (hasWorkHistory ? "İŞYERİNİ YENİDEN KAPAT" : "İŞYERİ KONTROLÜNÜ BAŞLAT"), 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        activeThumbColor: activeColor,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAddCustomButton(Color color) {
    return TextButton.icon(
      icon: Icon(Icons.add_circle_outline, color: color),
      label: Text("Kendi Özel Maddeni Ekle", style: TextStyle(color: color, fontSize: 16)),
      onPressed: _showAddTaskDialog,
    );
  }

  Widget _buildCustomTasksList(List<CheckTask> tasks) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 8),
          child: Text("Eklediğin Özel Maddeler", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return Card(
              color: const Color(0xFF1E1E1E),
              child: ListTile(
                title: Text(tasks[index].title),
                subtitle: Text(tasks[index].description, style: const TextStyle(fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                  onPressed: () => _deleteCustomTask(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddTaskDialog() {
    Color dialogAccentColor = const Color(0xFF1DB954);
    if (_selectedModeIndex == 1) dialogAccentColor = Colors.indigoAccent;
    if (_selectedModeIndex == 2) dialogAccentColor = Colors.amber;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Özel Kontrol Maddesi Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Madde Başlığı",
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: dialogAccentColor)),
                labelStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: "Açıklama",
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: dialogAccentColor)),
                labelStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dialogAccentColor),
            onPressed: _addCustomTask,
            child: const Text("Ekle", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}