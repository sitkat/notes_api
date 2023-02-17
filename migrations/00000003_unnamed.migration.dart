import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration3 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("_Category", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: true)]));
		database.addColumn("_Note", SchemaColumn.relationship("category", ManagedPropertyType.bigInteger, relatedTableName: "_Category", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
		database.alterColumn("_Note", "user", (c) {c.isNullable = true;c.deleteRule = DeleteRule.nullify;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    