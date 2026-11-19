# دليل الكلية الذكي — كلية التربية النوعية، جامعة المنوفية (أشمون)

## قبل النشر
لا تستخدم مشروع Supabase المسمى `restaurant-growth-os` لهذا الدليل؛ فهو مشروع مرتبط بتطبيق آخر. تم تفريغ `config.js` عمدًا لمنع أي اتصال بقاعدة بيانات ذلك التطبيق. يلزم إنشاء مشروع Supabase مستقل ثم تشغيل `supabase/schema.sql` وضبط Project URL وPublishable key في `config.js`.

## متطلبات الإعداد
1. تشغيل `supabase/schema.sql` على مشروع Supabase جديد ومستقل.
2. التأكد من تفعيل Data API وأن `public` ضمن Exposed schemas.
3. إنشاء حساب المشرف في Authentication ثم ضبط `app_metadata.role=admin` من لوحة Supabase، وليس `user_metadata`.
4. وضع Project URL وPublishable key فقط في `config.js`. ممنوع وضع Secret أو `service_role` في المتصفح.
5. ضبط Site URL وRedirect URLs في Auth على عنوان الموقع النهائي، وتفعيل Leaked Password Protection.
6. إيقاف التسجيل العام بعد إنشاء حساب المشرف ما لم تكن هناك حاجة إليه.

## التشغيل المحلي
من مجلد المشروع شغّل `python -m http.server 8000` ثم افتح `http://localhost:8000`. عند ترك الإعدادات فارغة يعمل الموقع في وضع معاينة ببيانات تجريبية للقراءة فقط.

## Render
Static Site، الفرع `main`، Build Command فارغ، Publish Directory `.`. إنشاء الخدمة متوقف حاليًا على استيفاء متطلبات فوترة Render.

## البيانات
لا توجد بيانات مواقع حقيقية مرفقة. لا تعتمد أسماء القاعات أو المعامل أو مواقعها إلا بعد التحقق منها مع إدارة الكلية.
