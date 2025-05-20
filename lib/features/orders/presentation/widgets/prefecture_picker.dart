import 'package:flutter/material.dart';

class PrefecturePicker extends StatelessWidget {
  final String selectedPrefecture;
  final ValueChanged<String> onChanged;

  const PrefecturePicker({
    super.key,
    required this.selectedPrefecture,
    required this.onChanged,
  });

  static const List<String> prefectures = [
    '北海道',
    '青森県',
    '岩手県',
    '宮城県',
    '秋田県',
    '山形県',
    '福島県',
    '茨城県',
    '栃木県',
    '群馬県',
    '埼玉県',
    '千葉県',
    '東京都',
    '神奈川県',
    '新潟県',
    '富山県',
    '石川県',
    '福井県',
    '山梨県',
    '長野県',
    '岐阜県',
    '静岡県',
    '愛知県',
    '三重県',
    '滋賀県',
    '京都府',
    '大阪府',
    '兵庫県',
    '奈良県',
    '和歌山県',
    '鳥取県',
    '島根県',
    '岡山県',
    '広島県',
    '山口県',
    '徳島県',
    '香川県',
    '愛媛県',
    '高知県',
    '福岡県',
    '佐賀県',
    '長崎県',
    '熊本県',
    '大分県',
    '宮崎県',
    '鹿児島県',
    '沖縄県',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: '都道府県',
        border: OutlineInputBorder(),
      ),
      value: selectedPrefecture.isEmpty ? null : selectedPrefecture,
      items: prefectures.map((prefecture) {
        return DropdownMenuItem<String>(
          value: prefecture,
          child: Text(prefecture),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '都道府県を選択してください';
        }
        return null;
      },
    );
  }
} 