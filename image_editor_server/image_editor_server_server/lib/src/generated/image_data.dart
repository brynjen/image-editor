/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ImageData
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ImageData._({
    this.id,
    required this.filename,
    required this.originalName,
    required this.mimeType,
    required this.size,
    DateTime? uploadedAt,
    this.processorType,
    this.instructions,
    this.processedAt,
    this.processedFilename,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory ImageData({
    int? id,
    required String filename,
    required String originalName,
    required String mimeType,
    required int size,
    DateTime? uploadedAt,
    String? processorType,
    String? instructions,
    DateTime? processedAt,
    String? processedFilename,
  }) = _ImageDataImpl;

  factory ImageData.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImageData(
      id: jsonSerialization['id'] as int?,
      filename: jsonSerialization['filename'] as String,
      originalName: jsonSerialization['originalName'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      size: jsonSerialization['size'] as int,
      uploadedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['uploadedAt']),
      processorType: jsonSerialization['processorType'] as String?,
      instructions: jsonSerialization['instructions'] as String?,
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt']),
      processedFilename: jsonSerialization['processedFilename'] as String?,
    );
  }

  static final t = ImageDataTable();

  static const db = ImageDataRepository._();

  @override
  int? id;

  String filename;

  String originalName;

  String mimeType;

  int size;

  DateTime uploadedAt;

  String? processorType;

  String? instructions;

  DateTime? processedAt;

  String? processedFilename;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ImageData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImageData copyWith({
    int? id,
    String? filename,
    String? originalName,
    String? mimeType,
    int? size,
    DateTime? uploadedAt,
    String? processorType,
    String? instructions,
    DateTime? processedAt,
    String? processedFilename,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'filename': filename,
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
      'uploadedAt': uploadedAt.toJson(),
      if (processorType != null) 'processorType': processorType,
      if (instructions != null) 'instructions': instructions,
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (processedFilename != null) 'processedFilename': processedFilename,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'filename': filename,
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
      'uploadedAt': uploadedAt.toJson(),
      if (processorType != null) 'processorType': processorType,
      if (instructions != null) 'instructions': instructions,
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (processedFilename != null) 'processedFilename': processedFilename,
    };
  }

  static ImageDataInclude include() {
    return ImageDataInclude._();
  }

  static ImageDataIncludeList includeList({
    _i1.WhereExpressionBuilder<ImageDataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ImageDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImageDataTable>? orderByList,
    ImageDataInclude? include,
  }) {
    return ImageDataIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ImageData.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ImageData.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ImageDataImpl extends ImageData {
  _ImageDataImpl({
    int? id,
    required String filename,
    required String originalName,
    required String mimeType,
    required int size,
    DateTime? uploadedAt,
    String? processorType,
    String? instructions,
    DateTime? processedAt,
    String? processedFilename,
  }) : super._(
          id: id,
          filename: filename,
          originalName: originalName,
          mimeType: mimeType,
          size: size,
          uploadedAt: uploadedAt,
          processorType: processorType,
          instructions: instructions,
          processedAt: processedAt,
          processedFilename: processedFilename,
        );

  /// Returns a shallow copy of this [ImageData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImageData copyWith({
    Object? id = _Undefined,
    String? filename,
    String? originalName,
    String? mimeType,
    int? size,
    DateTime? uploadedAt,
    Object? processorType = _Undefined,
    Object? instructions = _Undefined,
    Object? processedAt = _Undefined,
    Object? processedFilename = _Undefined,
  }) {
    return ImageData(
      id: id is int? ? id : this.id,
      filename: filename ?? this.filename,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      processorType:
          processorType is String? ? processorType : this.processorType,
      instructions: instructions is String? ? instructions : this.instructions,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
      processedFilename: processedFilename is String?
          ? processedFilename
          : this.processedFilename,
    );
  }
}

class ImageDataTable extends _i1.Table<int?> {
  ImageDataTable({super.tableRelation}) : super(tableName: 'image_data') {
    filename = _i1.ColumnString(
      'filename',
      this,
    );
    originalName = _i1.ColumnString(
      'originalName',
      this,
    );
    mimeType = _i1.ColumnString(
      'mimeType',
      this,
    );
    size = _i1.ColumnInt(
      'size',
      this,
    );
    uploadedAt = _i1.ColumnDateTime(
      'uploadedAt',
      this,
      hasDefault: true,
    );
    processorType = _i1.ColumnString(
      'processorType',
      this,
    );
    instructions = _i1.ColumnString(
      'instructions',
      this,
    );
    processedAt = _i1.ColumnDateTime(
      'processedAt',
      this,
    );
    processedFilename = _i1.ColumnString(
      'processedFilename',
      this,
    );
  }

  late final _i1.ColumnString filename;

  late final _i1.ColumnString originalName;

  late final _i1.ColumnString mimeType;

  late final _i1.ColumnInt size;

  late final _i1.ColumnDateTime uploadedAt;

  late final _i1.ColumnString processorType;

  late final _i1.ColumnString instructions;

  late final _i1.ColumnDateTime processedAt;

  late final _i1.ColumnString processedFilename;

  @override
  List<_i1.Column> get columns => [
        id,
        filename,
        originalName,
        mimeType,
        size,
        uploadedAt,
        processorType,
        instructions,
        processedAt,
        processedFilename,
      ];
}

class ImageDataInclude extends _i1.IncludeObject {
  ImageDataInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ImageData.t;
}

class ImageDataIncludeList extends _i1.IncludeList {
  ImageDataIncludeList._({
    _i1.WhereExpressionBuilder<ImageDataTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ImageData.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ImageData.t;
}

class ImageDataRepository {
  const ImageDataRepository._();

  /// Returns a list of [ImageData]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ImageData>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImageDataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ImageDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImageDataTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ImageData>(
      where: where?.call(ImageData.t),
      orderBy: orderBy?.call(ImageData.t),
      orderByList: orderByList?.call(ImageData.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ImageData] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ImageData?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImageDataTable>? where,
    int? offset,
    _i1.OrderByBuilder<ImageDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ImageDataTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ImageData>(
      where: where?.call(ImageData.t),
      orderBy: orderBy?.call(ImageData.t),
      orderByList: orderByList?.call(ImageData.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ImageData] by its [id] or null if no such row exists.
  Future<ImageData?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ImageData>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ImageData]s in the list and returns the inserted rows.
  ///
  /// The returned [ImageData]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ImageData>> insert(
    _i1.Session session,
    List<ImageData> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ImageData>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ImageData] and returns the inserted row.
  ///
  /// The returned [ImageData] will have its `id` field set.
  Future<ImageData> insertRow(
    _i1.Session session,
    ImageData row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ImageData>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ImageData]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ImageData>> update(
    _i1.Session session,
    List<ImageData> rows, {
    _i1.ColumnSelections<ImageDataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ImageData>(
      rows,
      columns: columns?.call(ImageData.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ImageData]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ImageData> updateRow(
    _i1.Session session,
    ImageData row, {
    _i1.ColumnSelections<ImageDataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ImageData>(
      row,
      columns: columns?.call(ImageData.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ImageData]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ImageData>> delete(
    _i1.Session session,
    List<ImageData> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ImageData>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ImageData].
  Future<ImageData> deleteRow(
    _i1.Session session,
    ImageData row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ImageData>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ImageData>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ImageDataTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ImageData>(
      where: where(ImageData.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ImageDataTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ImageData>(
      where: where?.call(ImageData.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
