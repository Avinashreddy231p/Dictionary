// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syllablesMeta = const VerificationMeta(
    'syllables',
  );
  @override
  late final GeneratedColumn<String> syllables = GeneratedColumn<String>(
    'syllables',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cefrMeta = const VerificationMeta('cefr');
  @override
  late final GeneratedColumn<String> cefr = GeneratedColumn<String>(
    'cefr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _etymologyMeta = const VerificationMeta(
    'etymology',
  );
  @override
  late final GeneratedColumn<String> etymology = GeneratedColumn<String>(
    'etymology',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstKnownUseMeta = const VerificationMeta(
    'firstKnownUse',
  );
  @override
  late final GeneratedColumn<String> firstKnownUse = GeneratedColumn<String>(
    'first_known_use',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _simpleMeaningMeta = const VerificationMeta(
    'simpleMeaning',
  );
  @override
  late final GeneratedColumn<String> simpleMeaning = GeneratedColumn<String>(
    'simple_meaning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextualMeaningMeta = const VerificationMeta(
    'contextualMeaning',
  );
  @override
  late final GeneratedColumn<String> contextualMeaning =
      GeneratedColumn<String>(
        'contextual_meaning',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    phonetic,
    partOfSpeech,
    syllables,
    cefr,
    etymology,
    firstKnownUse,
    simpleMeaning,
    contextualMeaning,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('syllables')) {
      context.handle(
        _syllablesMeta,
        syllables.isAcceptableOrUnknown(data['syllables']!, _syllablesMeta),
      );
    }
    if (data.containsKey('cefr')) {
      context.handle(
        _cefrMeta,
        cefr.isAcceptableOrUnknown(data['cefr']!, _cefrMeta),
      );
    }
    if (data.containsKey('etymology')) {
      context.handle(
        _etymologyMeta,
        etymology.isAcceptableOrUnknown(data['etymology']!, _etymologyMeta),
      );
    }
    if (data.containsKey('first_known_use')) {
      context.handle(
        _firstKnownUseMeta,
        firstKnownUse.isAcceptableOrUnknown(
          data['first_known_use']!,
          _firstKnownUseMeta,
        ),
      );
    }
    if (data.containsKey('simple_meaning')) {
      context.handle(
        _simpleMeaningMeta,
        simpleMeaning.isAcceptableOrUnknown(
          data['simple_meaning']!,
          _simpleMeaningMeta,
        ),
      );
    }
    if (data.containsKey('contextual_meaning')) {
      context.handle(
        _contextualMeaningMeta,
        contextualMeaning.isAcceptableOrUnknown(
          data['contextual_meaning']!,
          _contextualMeaningMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      ),
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      ),
      syllables: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}syllables'],
      ),
      cefr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cefr'],
      ),
      etymology: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etymology'],
      ),
      firstKnownUse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_known_use'],
      ),
      simpleMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}simple_meaning'],
      ),
      contextualMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contextual_meaning'],
      ),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;
  final String word;
  final String? phonetic;
  final String? partOfSpeech;
  final String? syllables;
  final String? cefr;
  final String? etymology;
  final String? firstKnownUse;
  final String? simpleMeaning;
  final String? contextualMeaning;
  const Word({
    required this.id,
    required this.word,
    this.phonetic,
    this.partOfSpeech,
    this.syllables,
    this.cefr,
    this.etymology,
    this.firstKnownUse,
    this.simpleMeaning,
    this.contextualMeaning,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || phonetic != null) {
      map['phonetic'] = Variable<String>(phonetic);
    }
    if (!nullToAbsent || partOfSpeech != null) {
      map['part_of_speech'] = Variable<String>(partOfSpeech);
    }
    if (!nullToAbsent || syllables != null) {
      map['syllables'] = Variable<String>(syllables);
    }
    if (!nullToAbsent || cefr != null) {
      map['cefr'] = Variable<String>(cefr);
    }
    if (!nullToAbsent || etymology != null) {
      map['etymology'] = Variable<String>(etymology);
    }
    if (!nullToAbsent || firstKnownUse != null) {
      map['first_known_use'] = Variable<String>(firstKnownUse);
    }
    if (!nullToAbsent || simpleMeaning != null) {
      map['simple_meaning'] = Variable<String>(simpleMeaning);
    }
    if (!nullToAbsent || contextualMeaning != null) {
      map['contextual_meaning'] = Variable<String>(contextualMeaning);
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      word: Value(word),
      phonetic: phonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(phonetic),
      partOfSpeech: partOfSpeech == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeech),
      syllables: syllables == null && nullToAbsent
          ? const Value.absent()
          : Value(syllables),
      cefr: cefr == null && nullToAbsent ? const Value.absent() : Value(cefr),
      etymology: etymology == null && nullToAbsent
          ? const Value.absent()
          : Value(etymology),
      firstKnownUse: firstKnownUse == null && nullToAbsent
          ? const Value.absent()
          : Value(firstKnownUse),
      simpleMeaning: simpleMeaning == null && nullToAbsent
          ? const Value.absent()
          : Value(simpleMeaning),
      contextualMeaning: contextualMeaning == null && nullToAbsent
          ? const Value.absent()
          : Value(contextualMeaning),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      phonetic: serializer.fromJson<String?>(json['phonetic']),
      partOfSpeech: serializer.fromJson<String?>(json['partOfSpeech']),
      syllables: serializer.fromJson<String?>(json['syllables']),
      cefr: serializer.fromJson<String?>(json['cefr']),
      etymology: serializer.fromJson<String?>(json['etymology']),
      firstKnownUse: serializer.fromJson<String?>(json['firstKnownUse']),
      simpleMeaning: serializer.fromJson<String?>(json['simpleMeaning']),
      contextualMeaning: serializer.fromJson<String?>(
        json['contextualMeaning'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'phonetic': serializer.toJson<String?>(phonetic),
      'partOfSpeech': serializer.toJson<String?>(partOfSpeech),
      'syllables': serializer.toJson<String?>(syllables),
      'cefr': serializer.toJson<String?>(cefr),
      'etymology': serializer.toJson<String?>(etymology),
      'firstKnownUse': serializer.toJson<String?>(firstKnownUse),
      'simpleMeaning': serializer.toJson<String?>(simpleMeaning),
      'contextualMeaning': serializer.toJson<String?>(contextualMeaning),
    };
  }

  Word copyWith({
    int? id,
    String? word,
    Value<String?> phonetic = const Value.absent(),
    Value<String?> partOfSpeech = const Value.absent(),
    Value<String?> syllables = const Value.absent(),
    Value<String?> cefr = const Value.absent(),
    Value<String?> etymology = const Value.absent(),
    Value<String?> firstKnownUse = const Value.absent(),
    Value<String?> simpleMeaning = const Value.absent(),
    Value<String?> contextualMeaning = const Value.absent(),
  }) => Word(
    id: id ?? this.id,
    word: word ?? this.word,
    phonetic: phonetic.present ? phonetic.value : this.phonetic,
    partOfSpeech: partOfSpeech.present ? partOfSpeech.value : this.partOfSpeech,
    syllables: syllables.present ? syllables.value : this.syllables,
    cefr: cefr.present ? cefr.value : this.cefr,
    etymology: etymology.present ? etymology.value : this.etymology,
    firstKnownUse: firstKnownUse.present
        ? firstKnownUse.value
        : this.firstKnownUse,
    simpleMeaning: simpleMeaning.present
        ? simpleMeaning.value
        : this.simpleMeaning,
    contextualMeaning: contextualMeaning.present
        ? contextualMeaning.value
        : this.contextualMeaning,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      syllables: data.syllables.present ? data.syllables.value : this.syllables,
      cefr: data.cefr.present ? data.cefr.value : this.cefr,
      etymology: data.etymology.present ? data.etymology.value : this.etymology,
      firstKnownUse: data.firstKnownUse.present
          ? data.firstKnownUse.value
          : this.firstKnownUse,
      simpleMeaning: data.simpleMeaning.present
          ? data.simpleMeaning.value
          : this.simpleMeaning,
      contextualMeaning: data.contextualMeaning.present
          ? data.contextualMeaning.value
          : this.contextualMeaning,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('syllables: $syllables, ')
          ..write('cefr: $cefr, ')
          ..write('etymology: $etymology, ')
          ..write('firstKnownUse: $firstKnownUse, ')
          ..write('simpleMeaning: $simpleMeaning, ')
          ..write('contextualMeaning: $contextualMeaning')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    phonetic,
    partOfSpeech,
    syllables,
    cefr,
    etymology,
    firstKnownUse,
    simpleMeaning,
    contextualMeaning,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.word == this.word &&
          other.phonetic == this.phonetic &&
          other.partOfSpeech == this.partOfSpeech &&
          other.syllables == this.syllables &&
          other.cefr == this.cefr &&
          other.etymology == this.etymology &&
          other.firstKnownUse == this.firstKnownUse &&
          other.simpleMeaning == this.simpleMeaning &&
          other.contextualMeaning == this.contextualMeaning);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> word;
  final Value<String?> phonetic;
  final Value<String?> partOfSpeech;
  final Value<String?> syllables;
  final Value<String?> cefr;
  final Value<String?> etymology;
  final Value<String?> firstKnownUse;
  final Value<String?> simpleMeaning;
  final Value<String?> contextualMeaning;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.syllables = const Value.absent(),
    this.cefr = const Value.absent(),
    this.etymology = const Value.absent(),
    this.firstKnownUse = const Value.absent(),
    this.simpleMeaning = const Value.absent(),
    this.contextualMeaning = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.syllables = const Value.absent(),
    this.cefr = const Value.absent(),
    this.etymology = const Value.absent(),
    this.firstKnownUse = const Value.absent(),
    this.simpleMeaning = const Value.absent(),
    this.contextualMeaning = const Value.absent(),
  }) : word = Value(word);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? phonetic,
    Expression<String>? partOfSpeech,
    Expression<String>? syllables,
    Expression<String>? cefr,
    Expression<String>? etymology,
    Expression<String>? firstKnownUse,
    Expression<String>? simpleMeaning,
    Expression<String>? contextualMeaning,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (phonetic != null) 'phonetic': phonetic,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (syllables != null) 'syllables': syllables,
      if (cefr != null) 'cefr': cefr,
      if (etymology != null) 'etymology': etymology,
      if (firstKnownUse != null) 'first_known_use': firstKnownUse,
      if (simpleMeaning != null) 'simple_meaning': simpleMeaning,
      if (contextualMeaning != null) 'contextual_meaning': contextualMeaning,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? word,
    Value<String?>? phonetic,
    Value<String?>? partOfSpeech,
    Value<String?>? syllables,
    Value<String?>? cefr,
    Value<String?>? etymology,
    Value<String?>? firstKnownUse,
    Value<String?>? simpleMeaning,
    Value<String?>? contextualMeaning,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      syllables: syllables ?? this.syllables,
      cefr: cefr ?? this.cefr,
      etymology: etymology ?? this.etymology,
      firstKnownUse: firstKnownUse ?? this.firstKnownUse,
      simpleMeaning: simpleMeaning ?? this.simpleMeaning,
      contextualMeaning: contextualMeaning ?? this.contextualMeaning,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (syllables.present) {
      map['syllables'] = Variable<String>(syllables.value);
    }
    if (cefr.present) {
      map['cefr'] = Variable<String>(cefr.value);
    }
    if (etymology.present) {
      map['etymology'] = Variable<String>(etymology.value);
    }
    if (firstKnownUse.present) {
      map['first_known_use'] = Variable<String>(firstKnownUse.value);
    }
    if (simpleMeaning.present) {
      map['simple_meaning'] = Variable<String>(simpleMeaning.value);
    }
    if (contextualMeaning.present) {
      map['contextual_meaning'] = Variable<String>(contextualMeaning.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('syllables: $syllables, ')
          ..write('cefr: $cefr, ')
          ..write('etymology: $etymology, ')
          ..write('firstKnownUse: $firstKnownUse, ')
          ..write('simpleMeaning: $simpleMeaning, ')
          ..write('contextualMeaning: $contextualMeaning')
          ..write(')'))
        .toString();
  }
}

class $DefinitionsTable extends Definitions
    with TableInfo<$DefinitionsTable, Definition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _senseNumberMeta = const VerificationMeta(
    'senseNumber',
  );
  @override
  late final GeneratedColumn<String> senseNumber = GeneratedColumn<String>(
    'sense_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    senseNumber,
    definition,
    labels,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Definition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('sense_number')) {
      context.handle(
        _senseNumberMeta,
        senseNumber.isAcceptableOrUnknown(
          data['sense_number']!,
          _senseNumberMeta,
        ),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Definition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Definition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      senseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sense_number'],
      ),
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      ),
    );
  }

  @override
  $DefinitionsTable createAlias(String alias) {
    return $DefinitionsTable(attachedDatabase, alias);
  }
}

class Definition extends DataClass implements Insertable<Definition> {
  final int id;
  final int wordId;
  final String? senseNumber;
  final String definition;
  final String? labels;
  const Definition({
    required this.id,
    required this.wordId,
    this.senseNumber,
    required this.definition,
    this.labels,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    if (!nullToAbsent || senseNumber != null) {
      map['sense_number'] = Variable<String>(senseNumber);
    }
    map['definition'] = Variable<String>(definition);
    if (!nullToAbsent || labels != null) {
      map['labels'] = Variable<String>(labels);
    }
    return map;
  }

  DefinitionsCompanion toCompanion(bool nullToAbsent) {
    return DefinitionsCompanion(
      id: Value(id),
      wordId: Value(wordId),
      senseNumber: senseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(senseNumber),
      definition: Value(definition),
      labels: labels == null && nullToAbsent
          ? const Value.absent()
          : Value(labels),
    );
  }

  factory Definition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Definition(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      senseNumber: serializer.fromJson<String?>(json['senseNumber']),
      definition: serializer.fromJson<String>(json['definition']),
      labels: serializer.fromJson<String?>(json['labels']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'senseNumber': serializer.toJson<String?>(senseNumber),
      'definition': serializer.toJson<String>(definition),
      'labels': serializer.toJson<String?>(labels),
    };
  }

  Definition copyWith({
    int? id,
    int? wordId,
    Value<String?> senseNumber = const Value.absent(),
    String? definition,
    Value<String?> labels = const Value.absent(),
  }) => Definition(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    senseNumber: senseNumber.present ? senseNumber.value : this.senseNumber,
    definition: definition ?? this.definition,
    labels: labels.present ? labels.value : this.labels,
  );
  Definition copyWithCompanion(DefinitionsCompanion data) {
    return Definition(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      senseNumber: data.senseNumber.present
          ? data.senseNumber.value
          : this.senseNumber,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      labels: data.labels.present ? data.labels.value : this.labels,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Definition(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('senseNumber: $senseNumber, ')
          ..write('definition: $definition, ')
          ..write('labels: $labels')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, wordId, senseNumber, definition, labels);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Definition &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.senseNumber == this.senseNumber &&
          other.definition == this.definition &&
          other.labels == this.labels);
}

class DefinitionsCompanion extends UpdateCompanion<Definition> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<String?> senseNumber;
  final Value<String> definition;
  final Value<String?> labels;
  const DefinitionsCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.senseNumber = const Value.absent(),
    this.definition = const Value.absent(),
    this.labels = const Value.absent(),
  });
  DefinitionsCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    this.senseNumber = const Value.absent(),
    required String definition,
    this.labels = const Value.absent(),
  }) : wordId = Value(wordId),
       definition = Value(definition);
  static Insertable<Definition> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<String>? senseNumber,
    Expression<String>? definition,
    Expression<String>? labels,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (senseNumber != null) 'sense_number': senseNumber,
      if (definition != null) 'definition': definition,
      if (labels != null) 'labels': labels,
    });
  }

  DefinitionsCompanion copyWith({
    Value<int>? id,
    Value<int>? wordId,
    Value<String?>? senseNumber,
    Value<String>? definition,
    Value<String?>? labels,
  }) {
    return DefinitionsCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      senseNumber: senseNumber ?? this.senseNumber,
      definition: definition ?? this.definition,
      labels: labels ?? this.labels,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (senseNumber.present) {
      map['sense_number'] = Variable<String>(senseNumber.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('senseNumber: $senseNumber, ')
          ..write('definition: $definition, ')
          ..write('labels: $labels')
          ..write(')'))
        .toString();
  }
}

class $ExamplesTable extends Examples with TableInfo<$ExamplesTable, Example> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<int> definitionId = GeneratedColumn<int>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES definitions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exampleTextMeta = const VerificationMeta(
    'exampleText',
  );
  @override
  late final GeneratedColumn<String> exampleText = GeneratedColumn<String>(
    'example_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, definitionId, exampleText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'examples';
  @override
  VerificationContext validateIntegrity(
    Insertable<Example> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('example_text')) {
      context.handle(
        _exampleTextMeta,
        exampleText.isAcceptableOrUnknown(
          data['example_text']!,
          _exampleTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exampleTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Example map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Example(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}definition_id'],
      )!,
      exampleText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_text'],
      )!,
    );
  }

  @override
  $ExamplesTable createAlias(String alias) {
    return $ExamplesTable(attachedDatabase, alias);
  }
}

class Example extends DataClass implements Insertable<Example> {
  final int id;
  final int definitionId;
  final String exampleText;
  const Example({
    required this.id,
    required this.definitionId,
    required this.exampleText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['definition_id'] = Variable<int>(definitionId);
    map['example_text'] = Variable<String>(exampleText);
    return map;
  }

  ExamplesCompanion toCompanion(bool nullToAbsent) {
    return ExamplesCompanion(
      id: Value(id),
      definitionId: Value(definitionId),
      exampleText: Value(exampleText),
    );
  }

  factory Example.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Example(
      id: serializer.fromJson<int>(json['id']),
      definitionId: serializer.fromJson<int>(json['definitionId']),
      exampleText: serializer.fromJson<String>(json['exampleText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'definitionId': serializer.toJson<int>(definitionId),
      'exampleText': serializer.toJson<String>(exampleText),
    };
  }

  Example copyWith({int? id, int? definitionId, String? exampleText}) =>
      Example(
        id: id ?? this.id,
        definitionId: definitionId ?? this.definitionId,
        exampleText: exampleText ?? this.exampleText,
      );
  Example copyWithCompanion(ExamplesCompanion data) {
    return Example(
      id: data.id.present ? data.id.value : this.id,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      exampleText: data.exampleText.present
          ? data.exampleText.value
          : this.exampleText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Example(')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('exampleText: $exampleText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, definitionId, exampleText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Example &&
          other.id == this.id &&
          other.definitionId == this.definitionId &&
          other.exampleText == this.exampleText);
}

class ExamplesCompanion extends UpdateCompanion<Example> {
  final Value<int> id;
  final Value<int> definitionId;
  final Value<String> exampleText;
  const ExamplesCompanion({
    this.id = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.exampleText = const Value.absent(),
  });
  ExamplesCompanion.insert({
    this.id = const Value.absent(),
    required int definitionId,
    required String exampleText,
  }) : definitionId = Value(definitionId),
       exampleText = Value(exampleText);
  static Insertable<Example> custom({
    Expression<int>? id,
    Expression<int>? definitionId,
    Expression<String>? exampleText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (definitionId != null) 'definition_id': definitionId,
      if (exampleText != null) 'example_text': exampleText,
    });
  }

  ExamplesCompanion copyWith({
    Value<int>? id,
    Value<int>? definitionId,
    Value<String>? exampleText,
  }) {
    return ExamplesCompanion(
      id: id ?? this.id,
      definitionId: definitionId ?? this.definitionId,
      exampleText: exampleText ?? this.exampleText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<int>(definitionId.value);
    }
    if (exampleText.present) {
      map['example_text'] = Variable<String>(exampleText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamplesCompanion(')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('exampleText: $exampleText')
          ..write(')'))
        .toString();
  }
}

class $SavedWordsTable extends SavedWords
    with TableInfo<$SavedWordsTable, SavedWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syllablesMeta = const VerificationMeta(
    'syllables',
  );
  @override
  late final GeneratedColumn<String> syllables = GeneratedColumn<String>(
    'syllables',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cefrMeta = const VerificationMeta('cefr');
  @override
  late final GeneratedColumn<String> cefr = GeneratedColumn<String>(
    'cefr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextSentenceMeta = const VerificationMeta(
    'contextSentence',
  );
  @override
  late final GeneratedColumn<String> contextSentence = GeneratedColumn<String>(
    'context_sentence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personalNoteMeta = const VerificationMeta(
    'personalNote',
  );
  @override
  late final GeneratedColumn<String> personalNote = GeneratedColumn<String>(
    'personal_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewStateMeta = const VerificationMeta(
    'reviewState',
  );
  @override
  late final GeneratedColumn<int> reviewState = GeneratedColumn<int>(
    'review_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    phonetic,
    partOfSpeech,
    meaning,
    example,
    syllables,
    cefr,
    dateAdded,
    contextSentence,
    personalNote,
    reviewState,
    isFavorite,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    if (data.containsKey('syllables')) {
      context.handle(
        _syllablesMeta,
        syllables.isAcceptableOrUnknown(data['syllables']!, _syllablesMeta),
      );
    }
    if (data.containsKey('cefr')) {
      context.handle(
        _cefrMeta,
        cefr.isAcceptableOrUnknown(data['cefr']!, _cefrMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('context_sentence')) {
      context.handle(
        _contextSentenceMeta,
        contextSentence.isAcceptableOrUnknown(
          data['context_sentence']!,
          _contextSentenceMeta,
        ),
      );
    }
    if (data.containsKey('personal_note')) {
      context.handle(
        _personalNoteMeta,
        personalNote.isAcceptableOrUnknown(
          data['personal_note']!,
          _personalNoteMeta,
        ),
      );
    }
    if (data.containsKey('review_state')) {
      context.handle(
        _reviewStateMeta,
        reviewState.isAcceptableOrUnknown(
          data['review_state']!,
          _reviewStateMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      ),
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      ),
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      ),
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
      syllables: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}syllables'],
      ),
      cefr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cefr'],
      ),
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      contextSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_sentence'],
      ),
      personalNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personal_note'],
      ),
      reviewState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_state'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
    );
  }

  @override
  $SavedWordsTable createAlias(String alias) {
    return $SavedWordsTable(attachedDatabase, alias);
  }
}

class SavedWord extends DataClass implements Insertable<SavedWord> {
  final int id;
  final String word;
  final String? phonetic;
  final String? partOfSpeech;
  final String? meaning;
  final String? example;
  final String? syllables;
  final String? cefr;
  final DateTime dateAdded;
  final String? contextSentence;
  final String? personalNote;
  final int reviewState;
  final bool isFavorite;
  final String? source;
  const SavedWord({
    required this.id,
    required this.word,
    this.phonetic,
    this.partOfSpeech,
    this.meaning,
    this.example,
    this.syllables,
    this.cefr,
    required this.dateAdded,
    this.contextSentence,
    this.personalNote,
    required this.reviewState,
    required this.isFavorite,
    this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || phonetic != null) {
      map['phonetic'] = Variable<String>(phonetic);
    }
    if (!nullToAbsent || partOfSpeech != null) {
      map['part_of_speech'] = Variable<String>(partOfSpeech);
    }
    if (!nullToAbsent || meaning != null) {
      map['meaning'] = Variable<String>(meaning);
    }
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    if (!nullToAbsent || syllables != null) {
      map['syllables'] = Variable<String>(syllables);
    }
    if (!nullToAbsent || cefr != null) {
      map['cefr'] = Variable<String>(cefr);
    }
    map['date_added'] = Variable<DateTime>(dateAdded);
    if (!nullToAbsent || contextSentence != null) {
      map['context_sentence'] = Variable<String>(contextSentence);
    }
    if (!nullToAbsent || personalNote != null) {
      map['personal_note'] = Variable<String>(personalNote);
    }
    map['review_state'] = Variable<int>(reviewState);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    return map;
  }

  SavedWordsCompanion toCompanion(bool nullToAbsent) {
    return SavedWordsCompanion(
      id: Value(id),
      word: Value(word),
      phonetic: phonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(phonetic),
      partOfSpeech: partOfSpeech == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeech),
      meaning: meaning == null && nullToAbsent
          ? const Value.absent()
          : Value(meaning),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
      syllables: syllables == null && nullToAbsent
          ? const Value.absent()
          : Value(syllables),
      cefr: cefr == null && nullToAbsent ? const Value.absent() : Value(cefr),
      dateAdded: Value(dateAdded),
      contextSentence: contextSentence == null && nullToAbsent
          ? const Value.absent()
          : Value(contextSentence),
      personalNote: personalNote == null && nullToAbsent
          ? const Value.absent()
          : Value(personalNote),
      reviewState: Value(reviewState),
      isFavorite: Value(isFavorite),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
    );
  }

  factory SavedWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedWord(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      phonetic: serializer.fromJson<String?>(json['phonetic']),
      partOfSpeech: serializer.fromJson<String?>(json['partOfSpeech']),
      meaning: serializer.fromJson<String?>(json['meaning']),
      example: serializer.fromJson<String?>(json['example']),
      syllables: serializer.fromJson<String?>(json['syllables']),
      cefr: serializer.fromJson<String?>(json['cefr']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      contextSentence: serializer.fromJson<String?>(json['contextSentence']),
      personalNote: serializer.fromJson<String?>(json['personalNote']),
      reviewState: serializer.fromJson<int>(json['reviewState']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'phonetic': serializer.toJson<String?>(phonetic),
      'partOfSpeech': serializer.toJson<String?>(partOfSpeech),
      'meaning': serializer.toJson<String?>(meaning),
      'example': serializer.toJson<String?>(example),
      'syllables': serializer.toJson<String?>(syllables),
      'cefr': serializer.toJson<String?>(cefr),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'contextSentence': serializer.toJson<String?>(contextSentence),
      'personalNote': serializer.toJson<String?>(personalNote),
      'reviewState': serializer.toJson<int>(reviewState),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'source': serializer.toJson<String?>(source),
    };
  }

  SavedWord copyWith({
    int? id,
    String? word,
    Value<String?> phonetic = const Value.absent(),
    Value<String?> partOfSpeech = const Value.absent(),
    Value<String?> meaning = const Value.absent(),
    Value<String?> example = const Value.absent(),
    Value<String?> syllables = const Value.absent(),
    Value<String?> cefr = const Value.absent(),
    DateTime? dateAdded,
    Value<String?> contextSentence = const Value.absent(),
    Value<String?> personalNote = const Value.absent(),
    int? reviewState,
    bool? isFavorite,
    Value<String?> source = const Value.absent(),
  }) => SavedWord(
    id: id ?? this.id,
    word: word ?? this.word,
    phonetic: phonetic.present ? phonetic.value : this.phonetic,
    partOfSpeech: partOfSpeech.present ? partOfSpeech.value : this.partOfSpeech,
    meaning: meaning.present ? meaning.value : this.meaning,
    example: example.present ? example.value : this.example,
    syllables: syllables.present ? syllables.value : this.syllables,
    cefr: cefr.present ? cefr.value : this.cefr,
    dateAdded: dateAdded ?? this.dateAdded,
    contextSentence: contextSentence.present
        ? contextSentence.value
        : this.contextSentence,
    personalNote: personalNote.present ? personalNote.value : this.personalNote,
    reviewState: reviewState ?? this.reviewState,
    isFavorite: isFavorite ?? this.isFavorite,
    source: source.present ? source.value : this.source,
  );
  SavedWord copyWithCompanion(SavedWordsCompanion data) {
    return SavedWord(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      example: data.example.present ? data.example.value : this.example,
      syllables: data.syllables.present ? data.syllables.value : this.syllables,
      cefr: data.cefr.present ? data.cefr.value : this.cefr,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      contextSentence: data.contextSentence.present
          ? data.contextSentence.value
          : this.contextSentence,
      personalNote: data.personalNote.present
          ? data.personalNote.value
          : this.personalNote,
      reviewState: data.reviewState.present
          ? data.reviewState.value
          : this.reviewState,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedWord(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('syllables: $syllables, ')
          ..write('cefr: $cefr, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('personalNote: $personalNote, ')
          ..write('reviewState: $reviewState, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    phonetic,
    partOfSpeech,
    meaning,
    example,
    syllables,
    cefr,
    dateAdded,
    contextSentence,
    personalNote,
    reviewState,
    isFavorite,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedWord &&
          other.id == this.id &&
          other.word == this.word &&
          other.phonetic == this.phonetic &&
          other.partOfSpeech == this.partOfSpeech &&
          other.meaning == this.meaning &&
          other.example == this.example &&
          other.syllables == this.syllables &&
          other.cefr == this.cefr &&
          other.dateAdded == this.dateAdded &&
          other.contextSentence == this.contextSentence &&
          other.personalNote == this.personalNote &&
          other.reviewState == this.reviewState &&
          other.isFavorite == this.isFavorite &&
          other.source == this.source);
}

class SavedWordsCompanion extends UpdateCompanion<SavedWord> {
  final Value<int> id;
  final Value<String> word;
  final Value<String?> phonetic;
  final Value<String?> partOfSpeech;
  final Value<String?> meaning;
  final Value<String?> example;
  final Value<String?> syllables;
  final Value<String?> cefr;
  final Value<DateTime> dateAdded;
  final Value<String?> contextSentence;
  final Value<String?> personalNote;
  final Value<int> reviewState;
  final Value<bool> isFavorite;
  final Value<String?> source;
  const SavedWordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.meaning = const Value.absent(),
    this.example = const Value.absent(),
    this.syllables = const Value.absent(),
    this.cefr = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.contextSentence = const Value.absent(),
    this.personalNote = const Value.absent(),
    this.reviewState = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.source = const Value.absent(),
  });
  SavedWordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    this.phonetic = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.meaning = const Value.absent(),
    this.example = const Value.absent(),
    this.syllables = const Value.absent(),
    this.cefr = const Value.absent(),
    required DateTime dateAdded,
    this.contextSentence = const Value.absent(),
    this.personalNote = const Value.absent(),
    this.reviewState = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.source = const Value.absent(),
  }) : word = Value(word),
       dateAdded = Value(dateAdded);
  static Insertable<SavedWord> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? phonetic,
    Expression<String>? partOfSpeech,
    Expression<String>? meaning,
    Expression<String>? example,
    Expression<String>? syllables,
    Expression<String>? cefr,
    Expression<DateTime>? dateAdded,
    Expression<String>? contextSentence,
    Expression<String>? personalNote,
    Expression<int>? reviewState,
    Expression<bool>? isFavorite,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (phonetic != null) 'phonetic': phonetic,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (meaning != null) 'meaning': meaning,
      if (example != null) 'example': example,
      if (syllables != null) 'syllables': syllables,
      if (cefr != null) 'cefr': cefr,
      if (dateAdded != null) 'date_added': dateAdded,
      if (contextSentence != null) 'context_sentence': contextSentence,
      if (personalNote != null) 'personal_note': personalNote,
      if (reviewState != null) 'review_state': reviewState,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (source != null) 'source': source,
    });
  }

  SavedWordsCompanion copyWith({
    Value<int>? id,
    Value<String>? word,
    Value<String?>? phonetic,
    Value<String?>? partOfSpeech,
    Value<String?>? meaning,
    Value<String?>? example,
    Value<String?>? syllables,
    Value<String?>? cefr,
    Value<DateTime>? dateAdded,
    Value<String?>? contextSentence,
    Value<String?>? personalNote,
    Value<int>? reviewState,
    Value<bool>? isFavorite,
    Value<String?>? source,
  }) {
    return SavedWordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      syllables: syllables ?? this.syllables,
      cefr: cefr ?? this.cefr,
      dateAdded: dateAdded ?? this.dateAdded,
      contextSentence: contextSentence ?? this.contextSentence,
      personalNote: personalNote ?? this.personalNote,
      reviewState: reviewState ?? this.reviewState,
      isFavorite: isFavorite ?? this.isFavorite,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (syllables.present) {
      map['syllables'] = Variable<String>(syllables.value);
    }
    if (cefr.present) {
      map['cefr'] = Variable<String>(cefr.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (contextSentence.present) {
      map['context_sentence'] = Variable<String>(contextSentence.value);
    }
    if (personalNote.present) {
      map['personal_note'] = Variable<String>(personalNote.value);
    }
    if (reviewState.present) {
      map['review_state'] = Variable<int>(reviewState.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedWordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('phonetic: $phonetic, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('syllables: $syllables, ')
          ..write('cefr: $cefr, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('contextSentence: $contextSentence, ')
          ..write('personalNote: $personalNote, ')
          ..write('reviewState: $reviewState, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0xFFE5D4FF'),
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSmartMeta = const VerificationMeta(
    'isSmart',
  );
  @override
  late final GeneratedColumn<bool> isSmart = GeneratedColumn<bool>(
    'is_smart',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_smart" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _smartTypeMeta = const VerificationMeta(
    'smartType',
  );
  @override
  late final GeneratedColumn<String> smartType = GeneratedColumn<String>(
    'smart_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    colorHex,
    iconName,
    tags,
    isSmart,
    smartType,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('is_smart')) {
      context.handle(
        _isSmartMeta,
        isSmart.isAcceptableOrUnknown(data['is_smart']!, _isSmartMeta),
      );
    }
    if (data.containsKey('smart_type')) {
      context.handle(
        _smartTypeMeta,
        smartType.isAcceptableOrUnknown(data['smart_type']!, _smartTypeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      isSmart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_smart'],
      )!,
      smartType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}smart_type'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final int id;
  final String title;
  final String? description;
  final String colorHex;
  final String? iconName;
  final String? tags;
  final bool isSmart;
  final String? smartType;
  final DateTime createdAt;
  const Collection({
    required this.id,
    required this.title,
    this.description,
    required this.colorHex,
    this.iconName,
    this.tags,
    required this.isSmart,
    this.smartType,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['color_hex'] = Variable<String>(colorHex);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['is_smart'] = Variable<bool>(isSmart);
    if (!nullToAbsent || smartType != null) {
      map['smart_type'] = Variable<String>(smartType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      colorHex: Value(colorHex),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      isSmart: Value(isSmart),
      smartType: smartType == null && nullToAbsent
          ? const Value.absent()
          : Value(smartType),
      createdAt: Value(createdAt),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      tags: serializer.fromJson<String?>(json['tags']),
      isSmart: serializer.fromJson<bool>(json['isSmart']),
      smartType: serializer.fromJson<String?>(json['smartType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'colorHex': serializer.toJson<String>(colorHex),
      'iconName': serializer.toJson<String?>(iconName),
      'tags': serializer.toJson<String?>(tags),
      'isSmart': serializer.toJson<bool>(isSmart),
      'smartType': serializer.toJson<String?>(smartType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Collection copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? colorHex,
    Value<String?> iconName = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    bool? isSmart,
    Value<String?> smartType = const Value.absent(),
    DateTime? createdAt,
  }) => Collection(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    colorHex: colorHex ?? this.colorHex,
    iconName: iconName.present ? iconName.value : this.iconName,
    tags: tags.present ? tags.value : this.tags,
    isSmart: isSmart ?? this.isSmart,
    smartType: smartType.present ? smartType.value : this.smartType,
    createdAt: createdAt ?? this.createdAt,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      tags: data.tags.present ? data.tags.value : this.tags,
      isSmart: data.isSmart.present ? data.isSmart.value : this.isSmart,
      smartType: data.smartType.present ? data.smartType.value : this.smartType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconName: $iconName, ')
          ..write('tags: $tags, ')
          ..write('isSmart: $isSmart, ')
          ..write('smartType: $smartType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    colorHex,
    iconName,
    tags,
    isSmart,
    smartType,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.colorHex == this.colorHex &&
          other.iconName == this.iconName &&
          other.tags == this.tags &&
          other.isSmart == this.isSmart &&
          other.smartType == this.smartType &&
          other.createdAt == this.createdAt);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> colorHex;
  final Value<String?> iconName;
  final Value<String?> tags;
  final Value<bool> isSmart;
  final Value<String?> smartType;
  final Value<DateTime> createdAt;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconName = const Value.absent(),
    this.tags = const Value.absent(),
    this.isSmart = const Value.absent(),
    this.smartType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconName = const Value.absent(),
    this.tags = const Value.absent(),
    this.isSmart = const Value.absent(),
    this.smartType = const Value.absent(),
    required DateTime createdAt,
  }) : title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? colorHex,
    Expression<String>? iconName,
    Expression<String>? tags,
    Expression<bool>? isSmart,
    Expression<String>? smartType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (colorHex != null) 'color_hex': colorHex,
      if (iconName != null) 'icon_name': iconName,
      if (tags != null) 'tags': tags,
      if (isSmart != null) 'is_smart': isSmart,
      if (smartType != null) 'smart_type': smartType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? colorHex,
    Value<String?>? iconName,
    Value<String?>? tags,
    Value<bool>? isSmart,
    Value<String?>? smartType,
    Value<DateTime>? createdAt,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      tags: tags ?? this.tags,
      isSmart: isSmart ?? this.isSmart,
      smartType: smartType ?? this.smartType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (isSmart.present) {
      map['is_smart'] = Variable<bool>(isSmart.value);
    }
    if (smartType.present) {
      map['smart_type'] = Variable<String>(smartType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconName: $iconName, ')
          ..write('tags: $tags, ')
          ..write('isSmart: $isSmart, ')
          ..write('smartType: $smartType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CollectionWordsTable extends CollectionWords
    with TableInfo<$CollectionWordsTable, CollectionWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _savedWordIdMeta = const VerificationMeta(
    'savedWordId',
  );
  @override
  late final GeneratedColumn<int> savedWordId = GeneratedColumn<int>(
    'saved_word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [collectionId, savedWordId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('saved_word_id')) {
      context.handle(
        _savedWordIdMeta,
        savedWordId.isAcceptableOrUnknown(
          data['saved_word_id']!,
          _savedWordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savedWordIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, savedWordId};
  @override
  CollectionWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionWord(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      )!,
      savedWordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_word_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CollectionWordsTable createAlias(String alias) {
    return $CollectionWordsTable(attachedDatabase, alias);
  }
}

class CollectionWord extends DataClass implements Insertable<CollectionWord> {
  final int collectionId;
  final int savedWordId;
  final DateTime addedAt;
  const CollectionWord({
    required this.collectionId,
    required this.savedWordId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<int>(collectionId);
    map['saved_word_id'] = Variable<int>(savedWordId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CollectionWordsCompanion toCompanion(bool nullToAbsent) {
    return CollectionWordsCompanion(
      collectionId: Value(collectionId),
      savedWordId: Value(savedWordId),
      addedAt: Value(addedAt),
    );
  }

  factory CollectionWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionWord(
      collectionId: serializer.fromJson<int>(json['collectionId']),
      savedWordId: serializer.fromJson<int>(json['savedWordId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<int>(collectionId),
      'savedWordId': serializer.toJson<int>(savedWordId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CollectionWord copyWith({
    int? collectionId,
    int? savedWordId,
    DateTime? addedAt,
  }) => CollectionWord(
    collectionId: collectionId ?? this.collectionId,
    savedWordId: savedWordId ?? this.savedWordId,
    addedAt: addedAt ?? this.addedAt,
  );
  CollectionWord copyWithCompanion(CollectionWordsCompanion data) {
    return CollectionWord(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      savedWordId: data.savedWordId.present
          ? data.savedWordId.value
          : this.savedWordId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionWord(')
          ..write('collectionId: $collectionId, ')
          ..write('savedWordId: $savedWordId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, savedWordId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionWord &&
          other.collectionId == this.collectionId &&
          other.savedWordId == this.savedWordId &&
          other.addedAt == this.addedAt);
}

class CollectionWordsCompanion extends UpdateCompanion<CollectionWord> {
  final Value<int> collectionId;
  final Value<int> savedWordId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CollectionWordsCompanion({
    this.collectionId = const Value.absent(),
    this.savedWordId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionWordsCompanion.insert({
    required int collectionId,
    required int savedWordId,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       savedWordId = Value(savedWordId),
       addedAt = Value(addedAt);
  static Insertable<CollectionWord> custom({
    Expression<int>? collectionId,
    Expression<int>? savedWordId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (savedWordId != null) 'saved_word_id': savedWordId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionWordsCompanion copyWith({
    Value<int>? collectionId,
    Value<int>? savedWordId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CollectionWordsCompanion(
      collectionId: collectionId ?? this.collectionId,
      savedWordId: savedWordId ?? this.savedWordId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (savedWordId.present) {
      map['saved_word_id'] = Variable<int>(savedWordId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionWordsCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('savedWordId: $savedWordId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, query, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentSearche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearche extends DataClass implements Insertable<RecentSearche> {
  final int id;
  final String query;
  final DateTime searchedAt;
  const RecentSearche({
    required this.id,
    required this.query,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      id: Value(id),
      query: Value(query),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearche(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  RecentSearche copyWith({int? id, String? query, DateTime? searchedAt}) =>
      RecentSearche(
        id: id ?? this.id,
        query: query ?? this.query,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  RecentSearche copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearche(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearche(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearche &&
          other.id == this.id &&
          other.query == this.query &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearche> {
  final Value<int> id;
  final Value<String> query;
  final Value<DateTime> searchedAt;
  const RecentSearchesCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required DateTime searchedAt,
  }) : query = Value(query),
       searchedAt = Value(searchedAt);
  static Insertable<RecentSearche> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<DateTime>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<DateTime>? searchedAt,
  }) {
    return RecentSearchesCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $DefinitionsTable definitions = $DefinitionsTable(this);
  late final $ExamplesTable examples = $ExamplesTable(this);
  late final $SavedWordsTable savedWords = $SavedWordsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionWordsTable collectionWords = $CollectionWordsTable(
    this,
  );
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    words,
    definitions,
    examples,
    savedWords,
    collections,
    collectionWords,
    recentSearches,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('definitions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'definitions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('examples', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_words', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'saved_words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_words', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  required String word,
  Value<String?> phonetic,
  Value<String?> partOfSpeech,
  Value<String?> syllables,
  Value<String?> cefr,
  Value<String?> etymology,
  Value<String?> firstKnownUse,
  Value<String?> simpleMeaning,
  Value<String?> contextualMeaning,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<String> word,
  Value<String?> phonetic,
  Value<String?> partOfSpeech,
  Value<String?> syllables,
  Value<String?> cefr,
  Value<String?> etymology,
  Value<String?> firstKnownUse,
  Value<String?> simpleMeaning,
  Value<String?> contextualMeaning,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DefinitionsTable, List<Definition>>
  _definitionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.definitions,
    aliasName: 'words__id__definitions__word_id',
  );

  $$DefinitionsTableProcessedTableManager get definitionsRefs {
    final manager = $$DefinitionsTableTableManager(
      $_db,
      $_db.definitions,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_definitionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syllables => $composableBuilder(
    column: $table.syllables,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cefr => $composableBuilder(
    column: $table.cefr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etymology => $composableBuilder(
    column: $table.etymology,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstKnownUse => $composableBuilder(
    column: $table.firstKnownUse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get simpleMeaning => $composableBuilder(
    column: $table.simpleMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextualMeaning => $composableBuilder(
    column: $table.contextualMeaning,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> definitionsRefs(
    Expression<bool> Function($$DefinitionsTableFilterComposer f) f,
  ) {
    final $$DefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.definitions,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.definitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syllables => $composableBuilder(
    column: $table.syllables,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cefr => $composableBuilder(
    column: $table.cefr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etymology => $composableBuilder(
    column: $table.etymology,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstKnownUse => $composableBuilder(
    column: $table.firstKnownUse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get simpleMeaning => $composableBuilder(
    column: $table.simpleMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextualMeaning => $composableBuilder(
    column: $table.contextualMeaning,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syllables =>
      $composableBuilder(column: $table.syllables, builder: (column) => column);

  GeneratedColumn<String> get cefr =>
      $composableBuilder(column: $table.cefr, builder: (column) => column);

  GeneratedColumn<String> get etymology =>
      $composableBuilder(column: $table.etymology, builder: (column) => column);

  GeneratedColumn<String> get firstKnownUse => $composableBuilder(
    column: $table.firstKnownUse,
    builder: (column) => column,
  );

  GeneratedColumn<String> get simpleMeaning => $composableBuilder(
    column: $table.simpleMeaning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextualMeaning => $composableBuilder(
    column: $table.contextualMeaning,
    builder: (column) => column,
  );

  Expression<T> definitionsRefs<T extends Object>(
    Expression<T> Function($$DefinitionsTableAnnotationComposer a) f,
  ) {
    final $$DefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.definitions,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.definitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({bool definitionsRefs})
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String?> phonetic = const Value.absent(),
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String?> syllables = const Value.absent(),
                Value<String?> cefr = const Value.absent(),
                Value<String?> etymology = const Value.absent(),
                Value<String?> firstKnownUse = const Value.absent(),
                Value<String?> simpleMeaning = const Value.absent(),
                Value<String?> contextualMeaning = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                word: word,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                syllables: syllables,
                cefr: cefr,
                etymology: etymology,
                firstKnownUse: firstKnownUse,
                simpleMeaning: simpleMeaning,
                contextualMeaning: contextualMeaning,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String word,
                Value<String?> phonetic = const Value.absent(),
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String?> syllables = const Value.absent(),
                Value<String?> cefr = const Value.absent(),
                Value<String?> etymology = const Value.absent(),
                Value<String?> firstKnownUse = const Value.absent(),
                Value<String?> simpleMeaning = const Value.absent(),
                Value<String?> contextualMeaning = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                word: word,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                syllables: syllables,
                cefr: cefr,
                etymology: etymology,
                firstKnownUse: firstKnownUse,
                simpleMeaning: simpleMeaning,
                contextualMeaning: contextualMeaning,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordsTable, Word>(table),
                  $$WordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({definitionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (definitionsRefs) db.definitions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (definitionsRefs)
                    await $_getPrefetchedData<Word, $WordsTable, Definition>(
                      currentTable: table,
                      referencedTable: $$WordsTableReferences
                          ._definitionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WordsTableReferences(db, table, p0).definitionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wordId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({bool definitionsRefs})
    >;
typedef $$DefinitionsTableCreateCompanionBuilder =
    DefinitionsCompanion Function({
      Value<int> id,
      required int wordId,
      Value<String?> senseNumber,
      required String definition,
      Value<String?> labels,
    });
typedef $$DefinitionsTableUpdateCompanionBuilder =
    DefinitionsCompanion Function({
      Value<int> id,
      Value<int> wordId,
      Value<String?> senseNumber,
      Value<String> definition,
      Value<String?> labels,
    });

final class $$DefinitionsTableReferences
    extends BaseReferences<_$AppDatabase, $DefinitionsTable, Definition> {
  $$DefinitionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('definitions__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExamplesTable, List<Example>> _examplesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.examples,
    aliasName: 'definitions__id__examples__definition_id',
  );

  $$ExamplesTableProcessedTableManager get examplesRefs {
    final manager = $$ExamplesTableTableManager(
      $_db,
      $_db.examples,
    ).filter((f) => f.definitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senseNumber => $composableBuilder(
    column: $table.senseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> examplesRefs(
    Expression<bool> Function($$ExamplesTableFilterComposer f) f,
  ) {
    final $$ExamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examples,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamplesTableFilterComposer(
            $db: $db,
            $table: $db.examples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senseNumber => $composableBuilder(
    column: $table.senseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senseNumber => $composableBuilder(
    column: $table.senseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> examplesRefs<T extends Object>(
    Expression<T> Function($$ExamplesTableAnnotationComposer a) f,
  ) {
    final $$ExamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examples,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.examples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DefinitionsTable,
          Definition,
          $$DefinitionsTableFilterComposer,
          $$DefinitionsTableOrderingComposer,
          $$DefinitionsTableAnnotationComposer,
          $$DefinitionsTableCreateCompanionBuilder,
          $$DefinitionsTableUpdateCompanionBuilder,
          (Definition, $$DefinitionsTableReferences),
          Definition,
          PrefetchHooks Function({bool wordId, bool examplesRefs})
        > {
  $$DefinitionsTableTableManager(_$AppDatabase db, $DefinitionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<String?> senseNumber = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String?> labels = const Value.absent(),
              }) => DefinitionsCompanion(
                id: id,
                wordId: wordId,
                senseNumber: senseNumber,
                definition: definition,
                labels: labels,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordId,
                Value<String?> senseNumber = const Value.absent(),
                required String definition,
                Value<String?> labels = const Value.absent(),
              }) => DefinitionsCompanion.insert(
                id: id,
                wordId: wordId,
                senseNumber: senseNumber,
                definition: definition,
                labels: labels,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DefinitionsTable, Definition>(table),
                  $$DefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false, examplesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (examplesRefs) db.examples],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.wordId,
                        referencedTable: $$DefinitionsTableReferences
                            ._wordIdTable(db),
                        referencedColumn: $$DefinitionsTableReferences
                            ._wordIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (examplesRefs)
                    await $_getPrefetchedData<
                      Definition,
                      $DefinitionsTable,
                      Example
                    >(
                      currentTable: table,
                      referencedTable: $$DefinitionsTableReferences
                          ._examplesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DefinitionsTableReferences(
                            db,
                            table,
                            p0,
                          ).examplesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.definitionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DefinitionsTable,
      Definition,
      $$DefinitionsTableFilterComposer,
      $$DefinitionsTableOrderingComposer,
      $$DefinitionsTableAnnotationComposer,
      $$DefinitionsTableCreateCompanionBuilder,
      $$DefinitionsTableUpdateCompanionBuilder,
      (Definition, $$DefinitionsTableReferences),
      Definition,
      PrefetchHooks Function({bool wordId, bool examplesRefs})
    >;
typedef $$ExamplesTableCreateCompanionBuilder = ExamplesCompanion Function({
  Value<int> id,
  required int definitionId,
  required String exampleText,
});
typedef $$ExamplesTableUpdateCompanionBuilder = ExamplesCompanion Function({
  Value<int> id,
  Value<int> definitionId,
  Value<String> exampleText,
});

final class $$ExamplesTableReferences
    extends BaseReferences<_$AppDatabase, $ExamplesTable, Example> {
  $$ExamplesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DefinitionsTable _definitionIdTable(_$AppDatabase db) =>
      db.definitions.createAlias('examples__definition_id__definitions__id');

  $$DefinitionsTableProcessedTableManager get definitionId {
    final $_column = $_itemColumn<int>('definition_id')!;

    final manager = $$DefinitionsTableTableManager(
      $_db,
      $_db.definitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_definitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExamplesTableFilterComposer
    extends Composer<_$AppDatabase, $ExamplesTable> {
  $$ExamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleText => $composableBuilder(
    column: $table.exampleText,
    builder: (column) => ColumnFilters(column),
  );

  $$DefinitionsTableFilterComposer get definitionId {
    final $$DefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.definitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.definitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamplesTable> {
  $$ExamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleText => $composableBuilder(
    column: $table.exampleText,
    builder: (column) => ColumnOrderings(column),
  );

  $$DefinitionsTableOrderingComposer get definitionId {
    final $$DefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.definitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.definitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamplesTable> {
  $$ExamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exampleText => $composableBuilder(
    column: $table.exampleText,
    builder: (column) => column,
  );

  $$DefinitionsTableAnnotationComposer get definitionId {
    final $$DefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.definitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.definitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamplesTable,
          Example,
          $$ExamplesTableFilterComposer,
          $$ExamplesTableOrderingComposer,
          $$ExamplesTableAnnotationComposer,
          $$ExamplesTableCreateCompanionBuilder,
          $$ExamplesTableUpdateCompanionBuilder,
          (Example, $$ExamplesTableReferences),
          Example,
          PrefetchHooks Function({bool definitionId})
        > {
  $$ExamplesTableTableManager(_$AppDatabase db, $ExamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> definitionId = const Value.absent(),
                Value<String> exampleText = const Value.absent(),
              }) => ExamplesCompanion(
                id: id,
                definitionId: definitionId,
                exampleText: exampleText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int definitionId,
                required String exampleText,
              }) => ExamplesCompanion.insert(
                id: id,
                definitionId: definitionId,
                exampleText: exampleText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExamplesTable, Example>(table),
                  $$ExamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({definitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (definitionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.definitionId,
                        referencedTable: $$ExamplesTableReferences
                            ._definitionIdTable(db),
                        referencedColumn: $$ExamplesTableReferences
                            ._definitionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamplesTable,
      Example,
      $$ExamplesTableFilterComposer,
      $$ExamplesTableOrderingComposer,
      $$ExamplesTableAnnotationComposer,
      $$ExamplesTableCreateCompanionBuilder,
      $$ExamplesTableUpdateCompanionBuilder,
      (Example, $$ExamplesTableReferences),
      Example,
      PrefetchHooks Function({bool definitionId})
    >;
typedef $$SavedWordsTableCreateCompanionBuilder = SavedWordsCompanion Function({
  Value<int> id,
  required String word,
  Value<String?> phonetic,
  Value<String?> partOfSpeech,
  Value<String?> meaning,
  Value<String?> example,
  Value<String?> syllables,
  Value<String?> cefr,
  required DateTime dateAdded,
  Value<String?> contextSentence,
  Value<String?> personalNote,
  Value<int> reviewState,
  Value<bool> isFavorite,
  Value<String?> source,
});
typedef $$SavedWordsTableUpdateCompanionBuilder = SavedWordsCompanion Function({
  Value<int> id,
  Value<String> word,
  Value<String?> phonetic,
  Value<String?> partOfSpeech,
  Value<String?> meaning,
  Value<String?> example,
  Value<String?> syllables,
  Value<String?> cefr,
  Value<DateTime> dateAdded,
  Value<String?> contextSentence,
  Value<String?> personalNote,
  Value<int> reviewState,
  Value<bool> isFavorite,
  Value<String?> source,
});

final class $$SavedWordsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedWordsTable, SavedWord> {
  $$SavedWordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionWordsTable, List<CollectionWord>>
  _collectionWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionWords,
    aliasName: 'saved_words__id__collection_words__saved_word_id',
  );

  $$CollectionWordsTableProcessedTableManager get collectionWordsRefs {
    final manager = $$CollectionWordsTableTableManager(
      $_db,
      $_db.collectionWords,
    ).filter((f) => f.savedWordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionWordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavedWordsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedWordsTable> {
  $$SavedWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syllables => $composableBuilder(
    column: $table.syllables,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cefr => $composableBuilder(
    column: $table.cefr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalNote => $composableBuilder(
    column: $table.personalNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewState => $composableBuilder(
    column: $table.reviewState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collectionWordsRefs(
    Expression<bool> Function($$CollectionWordsTableFilterComposer f) f,
  ) {
    final $$CollectionWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionWords,
      getReferencedColumn: (t) => t.savedWordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionWordsTableFilterComposer(
            $db: $db,
            $table: $db.collectionWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavedWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedWordsTable> {
  $$SavedWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syllables => $composableBuilder(
    column: $table.syllables,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cefr => $composableBuilder(
    column: $table.cefr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalNote => $composableBuilder(
    column: $table.personalNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewState => $composableBuilder(
    column: $table.reviewState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedWordsTable> {
  $$SavedWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<String> get syllables =>
      $composableBuilder(column: $table.syllables, builder: (column) => column);

  GeneratedColumn<String> get cefr =>
      $composableBuilder(column: $table.cefr, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<String> get contextSentence => $composableBuilder(
    column: $table.contextSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalNote => $composableBuilder(
    column: $table.personalNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewState => $composableBuilder(
    column: $table.reviewState,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  Expression<T> collectionWordsRefs<T extends Object>(
    Expression<T> Function($$CollectionWordsTableAnnotationComposer a) f,
  ) {
    final $$CollectionWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionWords,
      getReferencedColumn: (t) => t.savedWordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavedWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedWordsTable,
          SavedWord,
          $$SavedWordsTableFilterComposer,
          $$SavedWordsTableOrderingComposer,
          $$SavedWordsTableAnnotationComposer,
          $$SavedWordsTableCreateCompanionBuilder,
          $$SavedWordsTableUpdateCompanionBuilder,
          (SavedWord, $$SavedWordsTableReferences),
          SavedWord,
          PrefetchHooks Function({bool collectionWordsRefs})
        > {
  $$SavedWordsTableTableManager(_$AppDatabase db, $SavedWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String?> phonetic = const Value.absent(),
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String?> meaning = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<String?> syllables = const Value.absent(),
                Value<String?> cefr = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<String?> contextSentence = const Value.absent(),
                Value<String?> personalNote = const Value.absent(),
                Value<int> reviewState = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> source = const Value.absent(),
              }) => SavedWordsCompanion(
                id: id,
                word: word,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                meaning: meaning,
                example: example,
                syllables: syllables,
                cefr: cefr,
                dateAdded: dateAdded,
                contextSentence: contextSentence,
                personalNote: personalNote,
                reviewState: reviewState,
                isFavorite: isFavorite,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String word,
                Value<String?> phonetic = const Value.absent(),
                Value<String?> partOfSpeech = const Value.absent(),
                Value<String?> meaning = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<String?> syllables = const Value.absent(),
                Value<String?> cefr = const Value.absent(),
                required DateTime dateAdded,
                Value<String?> contextSentence = const Value.absent(),
                Value<String?> personalNote = const Value.absent(),
                Value<int> reviewState = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> source = const Value.absent(),
              }) => SavedWordsCompanion.insert(
                id: id,
                word: word,
                phonetic: phonetic,
                partOfSpeech: partOfSpeech,
                meaning: meaning,
                example: example,
                syllables: syllables,
                cefr: cefr,
                dateAdded: dateAdded,
                contextSentence: contextSentence,
                personalNote: personalNote,
                reviewState: reviewState,
                isFavorite: isFavorite,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavedWordsTable, SavedWord>(table),
                  $$SavedWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionWordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (collectionWordsRefs) db.collectionWords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collectionWordsRefs)
                    await $_getPrefetchedData<
                      SavedWord,
                      $SavedWordsTable,
                      CollectionWord
                    >(
                      currentTable: table,
                      referencedTable: $$SavedWordsTableReferences
                          ._collectionWordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SavedWordsTableReferences(
                            db,
                            table,
                            p0,
                          ).collectionWordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.savedWordId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SavedWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedWordsTable,
      SavedWord,
      $$SavedWordsTableFilterComposer,
      $$SavedWordsTableOrderingComposer,
      $$SavedWordsTableAnnotationComposer,
      $$SavedWordsTableCreateCompanionBuilder,
      $$SavedWordsTableUpdateCompanionBuilder,
      (SavedWord, $$SavedWordsTableReferences),
      SavedWord,
      PrefetchHooks Function({bool collectionWordsRefs})
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<String> colorHex,
      Value<String?> iconName,
      Value<String?> tags,
      Value<bool> isSmart,
      Value<String?> smartType,
      required DateTime createdAt,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<String> colorHex,
      Value<String?> iconName,
      Value<String?> tags,
      Value<bool> isSmart,
      Value<String?> smartType,
      Value<DateTime> createdAt,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionWordsTable, List<CollectionWord>>
  _collectionWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionWords,
    aliasName: 'collections__id__collection_words__collection_id',
  );

  $$CollectionWordsTableProcessedTableManager get collectionWordsRefs {
    final manager = $$CollectionWordsTableTableManager(
      $_db,
      $_db.collectionWords,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionWordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSmart => $composableBuilder(
    column: $table.isSmart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smartType => $composableBuilder(
    column: $table.smartType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collectionWordsRefs(
    Expression<bool> Function($$CollectionWordsTableFilterComposer f) f,
  ) {
    final $$CollectionWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionWords,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionWordsTableFilterComposer(
            $db: $db,
            $table: $db.collectionWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSmart => $composableBuilder(
    column: $table.isSmart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smartType => $composableBuilder(
    column: $table.smartType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isSmart =>
      $composableBuilder(column: $table.isSmart, builder: (column) => column);

  GeneratedColumn<String> get smartType =>
      $composableBuilder(column: $table.smartType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> collectionWordsRefs<T extends Object>(
    Expression<T> Function($$CollectionWordsTableAnnotationComposer a) f,
  ) {
    final $$CollectionWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionWords,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (Collection, $$CollectionsTableReferences),
          Collection,
          PrefetchHooks Function({bool collectionWordsRefs})
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<bool> isSmart = const Value.absent(),
                Value<String?> smartType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                title: title,
                description: description,
                colorHex: colorHex,
                iconName: iconName,
                tags: tags,
                isSmart: isSmart,
                smartType: smartType,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<bool> isSmart = const Value.absent(),
                Value<String?> smartType = const Value.absent(),
                required DateTime createdAt,
              }) => CollectionsCompanion.insert(
                id: id,
                title: title,
                description: description,
                colorHex: colorHex,
                iconName: iconName,
                tags: tags,
                isSmart: isSmart,
                smartType: smartType,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, Collection>(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionWordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (collectionWordsRefs) db.collectionWords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collectionWordsRefs)
                    await $_getPrefetchedData<
                      Collection,
                      $CollectionsTable,
                      CollectionWord
                    >(
                      currentTable: table,
                      referencedTable: $$CollectionsTableReferences
                          ._collectionWordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CollectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).collectionWordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.collectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (Collection, $$CollectionsTableReferences),
      Collection,
      PrefetchHooks Function({bool collectionWordsRefs})
    >;
typedef $$CollectionWordsTableCreateCompanionBuilder =
    CollectionWordsCompanion Function({
      required int collectionId,
      required int savedWordId,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$CollectionWordsTableUpdateCompanionBuilder =
    CollectionWordsCompanion Function({
      Value<int> collectionId,
      Value<int> savedWordId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$CollectionWordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CollectionWordsTable, CollectionWord> {
  $$CollectionWordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) => db
      .collections
      .createAlias('collection_words__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SavedWordsTable _savedWordIdTable(_$AppDatabase db) => db.savedWords
      .createAlias('collection_words__saved_word_id__saved_words__id');

  $$SavedWordsTableProcessedTableManager get savedWordId {
    final $_column = $_itemColumn<int>('saved_word_id')!;

    final manager = $$SavedWordsTableTableManager(
      $_db,
      $_db.savedWords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedWordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionWordsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionWordsTable> {
  $$CollectionWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedWordsTableFilterComposer get savedWordId {
    final $$SavedWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedWordId,
      referencedTable: $db.savedWords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedWordsTableFilterComposer(
            $db: $db,
            $table: $db.savedWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionWordsTable> {
  $$CollectionWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedWordsTableOrderingComposer get savedWordId {
    final $$SavedWordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedWordId,
      referencedTable: $db.savedWords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedWordsTableOrderingComposer(
            $db: $db,
            $table: $db.savedWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionWordsTable> {
  $$CollectionWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedWordsTableAnnotationComposer get savedWordId {
    final $$SavedWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedWordId,
      referencedTable: $db.savedWords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionWordsTable,
          CollectionWord,
          $$CollectionWordsTableFilterComposer,
          $$CollectionWordsTableOrderingComposer,
          $$CollectionWordsTableAnnotationComposer,
          $$CollectionWordsTableCreateCompanionBuilder,
          $$CollectionWordsTableUpdateCompanionBuilder,
          (CollectionWord, $$CollectionWordsTableReferences),
          CollectionWord,
          PrefetchHooks Function({bool collectionId, bool savedWordId})
        > {
  $$CollectionWordsTableTableManager(
    _$AppDatabase db,
    $CollectionWordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> collectionId = const Value.absent(),
                Value<int> savedWordId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionWordsCompanion(
                collectionId: collectionId,
                savedWordId: savedWordId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int collectionId,
                required int savedWordId,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectionWordsCompanion.insert(
                collectionId: collectionId,
                savedWordId: savedWordId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionWordsTable, CollectionWord>(table),
                  $$CollectionWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false, savedWordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $$CollectionWordsTableReferences
                            ._collectionIdTable(db),
                        referencedColumn: $$CollectionWordsTableReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (savedWordId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.savedWordId,
                        referencedTable: $$CollectionWordsTableReferences
                            ._savedWordIdTable(db),
                        referencedColumn: $$CollectionWordsTableReferences
                            ._savedWordIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CollectionWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionWordsTable,
      CollectionWord,
      $$CollectionWordsTableFilterComposer,
      $$CollectionWordsTableOrderingComposer,
      $$CollectionWordsTableAnnotationComposer,
      $$CollectionWordsTableCreateCompanionBuilder,
      $$CollectionWordsTableUpdateCompanionBuilder,
      (CollectionWord, $$CollectionWordsTableReferences),
      CollectionWord,
      PrefetchHooks Function({bool collectionId, bool savedWordId})
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> id,
      required String query,
      required DateTime searchedAt,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<DateTime> searchedAt,
    });

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearche,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (
            RecentSearche,
            BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>,
          ),
          RecentSearche,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$AppDatabase db,
    $RecentSearchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
              }) => RecentSearchesCompanion(
                id: id,
                query: query,
                searchedAt: searchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required DateTime searchedAt,
              }) => RecentSearchesCompanion.insert(
                id: id,
                query: query,
                searchedAt: searchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentSearchesTable, RecentSearche>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentSearchesTable,
                    RecentSearche
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearche,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (
        RecentSearche,
        BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>,
      ),
      RecentSearche,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$DefinitionsTableTableManager get definitions =>
      $$DefinitionsTableTableManager(_db, _db.definitions);
  $$ExamplesTableTableManager get examples =>
      $$ExamplesTableTableManager(_db, _db.examples);
  $$SavedWordsTableTableManager get savedWords =>
      $$SavedWordsTableTableManager(_db, _db.savedWords);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionWordsTableTableManager get collectionWords =>
      $$CollectionWordsTableTableManager(_db, _db.collectionWords);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
}
