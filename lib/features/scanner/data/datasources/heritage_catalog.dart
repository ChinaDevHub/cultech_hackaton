import '../../../../core/domain/heritage_category.dart';
import '../../domain/entities/scan_media.dart';
import '../../domain/entities/scan_result.dart';

/// Reference slice of the national heritage registry used by the offline
/// demo engine (the production engine queries the vector database instead).
abstract final class HeritageCatalog {
  static const HeritageOrigin shirvanBoteh = HeritageOrigin(
    school: 'Şirvan Xalçaçılıq Məktəbi',
    motif: 'Boteh (Buta) Naxışı',
    region: 'Şamaxı, Şirvan',
    era: 'XVIII–XIX əsr',
    registryId: 'AZ-HRT-CRP-0412',
    category: HeritageCategory.carpet,
    recognition: 'UNESCO · Azərbaycan xalçaçılıq sənəti (2010)',
  );

  static const HeritageOrigin qarabaghXatai = HeritageOrigin(
    school: 'Qarabağ Xalçaçılıq Məktəbi',
    motif: "'Xətai' kompozisiyası",
    region: 'Şuşa, Qarabağ',
    era: 'XIX əsr',
    registryId: 'AZ-HRT-CRP-0188',
    category: HeritageCategory.carpet,
    recognition: 'UNESCO · Azərbaycan xalçaçılıq sənəti (2010)',
  );

  static const HeritageOrigin qazaxShixli = HeritageOrigin(
    school: 'Qazax Xalçaçılıq Məktəbi',
    motif: "'Şıxlı' göl motivi",
    region: 'Qazax',
    era: 'XIX əsr',
    registryId: 'AZ-HRT-CRP-0275',
    category: HeritageCategory.carpet,
    recognition: 'UNESCO · Azərbaycan xalçaçılıq sənəti (2010)',
  );

  static const HeritageOrigin qubaQimil = HeritageOrigin(
    school: 'Quba Xalçaçılıq Məktəbi',
    motif: "'Qımıl' naxışı",
    region: 'Quba',
    era: 'XIX əsr',
    registryId: 'AZ-HRT-CRP-0331',
    category: HeritageCategory.carpet,
  );

  static const HeritageOrigin shakiShabaka = HeritageOrigin(
    school: 'Şəki Xan Sarayı',
    motif: 'Şəbəkə həndəsi ornamenti',
    region: 'Şəki',
    era: 'XVIII əsr',
    registryId: 'AZ-HRT-ORN-0057',
    category: HeritageCategory.ornament,
    recognition: 'UNESCO Dünya İrsi · Şəki tarixi mərkəzi (2019)',
  );

  static const HeritageOrigin mughamRast = HeritageOrigin(
    school: 'Azərbaycan Muğamı',
    motif: "'Rast' dəstgahı",
    region: 'Şuşa muğam məktəbi',
    era: 'Klassik repertuar',
    registryId: 'AZ-HRT-MUG-0004',
    category: HeritageCategory.mugham,
    recognition: 'UNESCO · Azərbaycan muğamı (2008)',
  );

  static const HeritageOrigin mughamSegah = HeritageOrigin(
    school: 'Azərbaycan Muğamı',
    motif: "'Segah' dəstgahı",
    region: 'Bakı muğam məktəbi',
    era: 'Klassik repertuar',
    registryId: 'AZ-HRT-MUG-0011',
    category: HeritageCategory.mugham,
    recognition: 'UNESCO · Azərbaycan muğamı (2008)',
  );

  static const HeritageOrigin tarSadiq = HeritageOrigin(
    school: 'Tar Sənətkarlığı',
    motif: 'Mirzə Sadıq tar tembri',
    region: 'Şuşa',
    era: 'XIX əsr',
    registryId: 'AZ-HRT-INS-0102',
    category: HeritageCategory.instrument,
    recognition: 'UNESCO · Tar sənətkarlığı və ifaçılığı (2012)',
  );

  static const HeritageOrigin kamanchaBayati = HeritageOrigin(
    school: 'Kamança Sənəti',
    motif: "'Bayatı-Şiraz' ifası",
    region: 'Bakı',
    era: 'XX əsr ənənəsi',
    registryId: 'AZ-HRT-INS-0140',
    category: HeritageCategory.instrument,
    recognition: 'UNESCO · Kamança sənəti (2017)',
  );

  static const HeritageOrigin balabanDilqemi = HeritageOrigin(
    school: 'Aşıq Sənəti',
    motif: "Balaban 'Dilqəmi' havası",
    region: 'Göyçə aşıq məktəbi',
    era: 'Şifahi ənənə',
    registryId: 'AZ-HRT-ASH-0023',
    category: HeritageCategory.instrument,
    recognition: 'UNESCO · Aşıq sənəti (2009)',
  );

  static const List<HeritageOrigin> visual = <HeritageOrigin>[
    shirvanBoteh,
    qarabaghXatai,
    qazaxShixli,
    qubaQimil,
    shakiShabaka,
  ];

  static const List<HeritageOrigin> audio = <HeritageOrigin>[
    mughamRast,
    mughamSegah,
    tarSadiq,
    kamanchaBayati,
    balabanDilqemi,
  ];

  static const List<String> visualSources = <String>[
    'Midjourney v6.1',
    'Stable Diffusion XL',
    'DALL·E 3',
    'Adobe Firefly 3',
  ];

  static const List<String> audioSources = <String>[
    'Suno v4',
    'Udio v1.5',
    'Stable Audio 2.0',
  ];

  static const List<String> licensees = <String>[
    'Caspian Pixel Studio',
    'Nar Games',
    'Silk Road Interactive',
  ];

  static List<HeritageOrigin> forKind(MediaKind kind) =>
      kind == MediaKind.image ? visual : audio;

  static List<String> sourcesForKind(MediaKind kind) =>
      kind == MediaKind.image ? visualSources : audioSources;
}
