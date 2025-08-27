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

abstract class ProcessingJob
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ProcessingJob._({
    this.id,
    required this.imageId,
    String? status,
    required this.processorType,
    required this.instructions,
    DateTime? createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.processingTimeMs,
    this.resultImageId,
    double? progress,
  })  : status = status ?? 'pending',
        createdAt = createdAt ?? DateTime.now(),
        progress = progress ?? 0.0;

  factory ProcessingJob({
    int? id,
    required int imageId,
    String? status,
    required String processorType,
    required String instructions,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    int? processingTimeMs,
    int? resultImageId,
    double? progress,
  }) = _ProcessingJobImpl;

  factory ProcessingJob.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProcessingJob(
      id: jsonSerialization['id'] as int?,
      imageId: jsonSerialization['imageId'] as int,
      status: jsonSerialization['status'] as String,
      processorType: jsonSerialization['processorType'] as String,
      instructions: jsonSerialization['instructions'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt']),
      errorMessage: jsonSerialization['errorMessage'] as String?,
      processingTimeMs: jsonSerialization['processingTimeMs'] as int?,
      resultImageId: jsonSerialization['resultImageId'] as int?,
      progress: (jsonSerialization['progress'] as num).toDouble(),
    );
  }

  static final t = ProcessingJobTable();

  static const db = ProcessingJobRepository._();

  @override
  int? id;

  int imageId;

  String status;

  String processorType;

  String instructions;

  DateTime createdAt;

  DateTime? startedAt;

  DateTime? completedAt;

  String? errorMessage;

  int? processingTimeMs;

  int? resultImageId;

  double progress;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProcessingJob]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProcessingJob copyWith({
    int? id,
    int? imageId,
    String? status,
    String? processorType,
    String? instructions,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    int? processingTimeMs,
    int? resultImageId,
    double? progress,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'imageId': imageId,
      'status': status,
      'processorType': processorType,
      'instructions': instructions,
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (processingTimeMs != null) 'processingTimeMs': processingTimeMs,
      if (resultImageId != null) 'resultImageId': resultImageId,
      'progress': progress,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'imageId': imageId,
      'status': status,
      'processorType': processorType,
      'instructions': instructions,
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (processingTimeMs != null) 'processingTimeMs': processingTimeMs,
      if (resultImageId != null) 'resultImageId': resultImageId,
      'progress': progress,
    };
  }

  static ProcessingJobInclude include() {
    return ProcessingJobInclude._();
  }

  static ProcessingJobIncludeList includeList({
    _i1.WhereExpressionBuilder<ProcessingJobTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProcessingJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProcessingJobTable>? orderByList,
    ProcessingJobInclude? include,
  }) {
    return ProcessingJobIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProcessingJob.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProcessingJob.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProcessingJobImpl extends ProcessingJob {
  _ProcessingJobImpl({
    int? id,
    required int imageId,
    String? status,
    required String processorType,
    required String instructions,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    int? processingTimeMs,
    int? resultImageId,
    double? progress,
  }) : super._(
          id: id,
          imageId: imageId,
          status: status,
          processorType: processorType,
          instructions: instructions,
          createdAt: createdAt,
          startedAt: startedAt,
          completedAt: completedAt,
          errorMessage: errorMessage,
          processingTimeMs: processingTimeMs,
          resultImageId: resultImageId,
          progress: progress,
        );

  /// Returns a shallow copy of this [ProcessingJob]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProcessingJob copyWith({
    Object? id = _Undefined,
    int? imageId,
    String? status,
    String? processorType,
    String? instructions,
    DateTime? createdAt,
    Object? startedAt = _Undefined,
    Object? completedAt = _Undefined,
    Object? errorMessage = _Undefined,
    Object? processingTimeMs = _Undefined,
    Object? resultImageId = _Undefined,
    double? progress,
  }) {
    return ProcessingJob(
      id: id is int? ? id : this.id,
      imageId: imageId ?? this.imageId,
      status: status ?? this.status,
      processorType: processorType ?? this.processorType,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      processingTimeMs:
          processingTimeMs is int? ? processingTimeMs : this.processingTimeMs,
      resultImageId: resultImageId is int? ? resultImageId : this.resultImageId,
      progress: progress ?? this.progress,
    );
  }
}

class ProcessingJobTable extends _i1.Table<int?> {
  ProcessingJobTable({super.tableRelation})
      : super(tableName: 'processing_jobs') {
    imageId = _i1.ColumnInt(
      'imageId',
      this,
    );
    status = _i1.ColumnString(
      'status',
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
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    startedAt = _i1.ColumnDateTime(
      'startedAt',
      this,
    );
    completedAt = _i1.ColumnDateTime(
      'completedAt',
      this,
    );
    errorMessage = _i1.ColumnString(
      'errorMessage',
      this,
    );
    processingTimeMs = _i1.ColumnInt(
      'processingTimeMs',
      this,
    );
    resultImageId = _i1.ColumnInt(
      'resultImageId',
      this,
    );
    progress = _i1.ColumnDouble(
      'progress',
      this,
      hasDefault: true,
    );
  }

  late final _i1.ColumnInt imageId;

  late final _i1.ColumnString status;

  late final _i1.ColumnString processorType;

  late final _i1.ColumnString instructions;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime startedAt;

  late final _i1.ColumnDateTime completedAt;

  late final _i1.ColumnString errorMessage;

  late final _i1.ColumnInt processingTimeMs;

  late final _i1.ColumnInt resultImageId;

  late final _i1.ColumnDouble progress;

  @override
  List<_i1.Column> get columns => [
        id,
        imageId,
        status,
        processorType,
        instructions,
        createdAt,
        startedAt,
        completedAt,
        errorMessage,
        processingTimeMs,
        resultImageId,
        progress,
      ];
}

class ProcessingJobInclude extends _i1.IncludeObject {
  ProcessingJobInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ProcessingJob.t;
}

class ProcessingJobIncludeList extends _i1.IncludeList {
  ProcessingJobIncludeList._({
    _i1.WhereExpressionBuilder<ProcessingJobTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProcessingJob.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ProcessingJob.t;
}

class ProcessingJobRepository {
  const ProcessingJobRepository._();

  /// Returns a list of [ProcessingJob]s matching the given query parameters.
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
  Future<List<ProcessingJob>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProcessingJobTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProcessingJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProcessingJobTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ProcessingJob>(
      where: where?.call(ProcessingJob.t),
      orderBy: orderBy?.call(ProcessingJob.t),
      orderByList: orderByList?.call(ProcessingJob.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ProcessingJob] matching the given query parameters.
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
  Future<ProcessingJob?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProcessingJobTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProcessingJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProcessingJobTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ProcessingJob>(
      where: where?.call(ProcessingJob.t),
      orderBy: orderBy?.call(ProcessingJob.t),
      orderByList: orderByList?.call(ProcessingJob.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ProcessingJob] by its [id] or null if no such row exists.
  Future<ProcessingJob?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ProcessingJob>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ProcessingJob]s in the list and returns the inserted rows.
  ///
  /// The returned [ProcessingJob]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ProcessingJob>> insert(
    _i1.Session session,
    List<ProcessingJob> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ProcessingJob>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ProcessingJob] and returns the inserted row.
  ///
  /// The returned [ProcessingJob] will have its `id` field set.
  Future<ProcessingJob> insertRow(
    _i1.Session session,
    ProcessingJob row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProcessingJob>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProcessingJob]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProcessingJob>> update(
    _i1.Session session,
    List<ProcessingJob> rows, {
    _i1.ColumnSelections<ProcessingJobTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProcessingJob>(
      rows,
      columns: columns?.call(ProcessingJob.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProcessingJob]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProcessingJob> updateRow(
    _i1.Session session,
    ProcessingJob row, {
    _i1.ColumnSelections<ProcessingJobTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProcessingJob>(
      row,
      columns: columns?.call(ProcessingJob.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ProcessingJob]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProcessingJob>> delete(
    _i1.Session session,
    List<ProcessingJob> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProcessingJob>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProcessingJob].
  Future<ProcessingJob> deleteRow(
    _i1.Session session,
    ProcessingJob row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProcessingJob>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProcessingJob>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ProcessingJobTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProcessingJob>(
      where: where(ProcessingJob.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProcessingJobTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProcessingJob>(
      where: where?.call(ProcessingJob.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
