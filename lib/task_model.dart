class CheckTask {
  final String title;        // Görevin başlığı (Örn: Pencereler)
  final String description;  // Görevin açıklaması (Örn: Pencereleri kapat.)
  bool isChecked;            // Kontrol edildi mi? (true / false)

  CheckTask({
    required this.title,
    required this.description,
    this.isChecked = false,  // Varsayılan olarak başta kontrol edilmedi (false) kabul ediyoruz
  });
}