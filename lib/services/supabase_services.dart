// ไฟล์นี้จะประกอบด้วยโค้ดคำสั่งการทำงานต่างๆ กับ Supabase
// เช่น อัปโหลดไฟล์, เพิ่ม ลบ แก้ไข ค้นหา/ตรวจสอบ/ดึง/ดู ข้อมูลในตาราง
import 'package:flutter_tracker_app/models/run.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SupabaseService {
  //*** สิ่งสำคัญจะต้องสร้าง instance/object/ตัวแทน ที่จะทำงานกับ Supabase ***/
  final supabase = Supabase.instance.client;

  //---- ต่อจากนี้ก็จะเป็นส่วนของเมธอดการทำงานต่างๆ กับ Supabase ----

  // เมธอดอัปโหลดไฟล์ไปยัง bucket ที่อยู่ใน storage ของ Supabase --------------------------------
  Future<String> uploadImageFile(XFile xfile) async {
    //ตั้งชื่อไฟล์เพื่อไม่ให้ซ้ำกันเวลาอยู่ใน bucket
    final newFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';

    //upload ไฟล์
    await supabase.storage.from('run_bk').uploadBinary(
          newFileName,
          await xfile.readAsBytes(),
          fileOptions: FileOptions(contentType: xfile.mimeType),
        );

    //คือค่าที่อยู่ของไฟล์ที่อัปโหลดเข้าไปใน bucket เพื่อเอาไปบันทึกลง table
    return supabase.storage.from('run_bk').getPublicUrl(newFileName);
  }

  // เมธอดเพิ่มข้อมูลไปยัง table ที่อยู่ใน database ของ Supabase --------------------------------
  Future<void> insertRun(Run run) async {
    await supabase.from('run_tb').insert(run.toJson());
  }

  // เมธอดดึงข้อมูลทั้งหมดจาก table ที่อยู่ใน database ของ Supabase ----------------------------
  Future<List<Run>> getAllRuns() async {
    //คำสั่งดึงข้อมูลจาก supabase
    final response = await supabase.from('run_tb').select('*');
    //เอาข้อมูลที่ดึงมาซึ่งเป็น JSON แปลงเป็นข้อมูล Object ที่ใช้ใน Project
    return response.map((e) => Run.fromJson(e)).toList();
  }

  // เมธอดลบไฟล์ที่ bucket ที่อยู่ใน storage ของ Supabase --------------------------------
  Future<void> deleteImageFile(String fileName) async {
    await supabase.storage.from('run_bk').remove([fileName]);
  }

  // เมธอดแก้ไขข้อมูลใน table ที่อยู่ใน database ของ Supabase -----------------------------
  Future<void> updateRun(Run run, String id) async {
    await supabase.from('run_tb').update(run.toJson()).eq('id', id);
  }

  // เมธอดลบข้อมูลออกจาก table ที่อยู่ใน database ของ Supabase --------------------------------
  Future<void> deleteRun(String id) async {
    await supabase.from('run_tb').delete().eq('id', id);
  }
}
