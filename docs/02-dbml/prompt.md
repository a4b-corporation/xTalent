##
hãy xem tất cả các file design dbml ở /Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/Product/xTalent/db; lưu ý module time & absence có 1 phiên bản nhỏ của sub module absence và 1 file dbml của cả module -> tôi chưa rõ là nó có conflict không nên bạn cần load cả 2 và note nếu nó conflict nhé; và trả lời các câu hỏi sau giúp tôi
1. compensation basis hiện tại đã có thể cover tất cả các tình huống lương theo ngày công, sản phẩm, các loại phụ cấp theo emp hay chưa?
2. mối quan hệ worker -> working relationship -> employee -> assignment; giả sử 1 emp có nhiều assignment và có thể có nhiều bảng lương thì cách thiết kế hiện tại đã hợp lý chưa? và khi đó mối quan hệ assignment -> compensation basis với salary basis ra sao?
3. Hiện tại công được gom theo timesheet, nếu muốn tính rate khác biệt cho từng khung giờ công thì có được không? giả sử 1 giảng viên thì nếu punch giờ giảng dạy sẽ có rate khác, giờ nghiên cứu rate khác và giờ hội thảo rate khác thì có cần sinh nhiều timesheet? hay có thể sinh 1 timesheet và có nhiều rate? và nếu có nhiều rate thì có cần sinh nhiều compensation basis không?
4. Tôi đang hình dung là eligibilities sẽ là đơn vị cơ bản để gom nhóm trong việc xác lập các total rewards package, tính lương; ví dụ như ở view config thì eligibility sẽ như 1 dạng group động để biết rằng eligibility rule này có những nhân viên nào; nhưng khi ở execution view thì ở 1 emp chúng ta có thể biết được các package nào, total rewards component nào, hay payroll element nào đang effect vào employee này thì cách design hiện tại đã đáp ứng chưa?


##
Hãy giúp tôi chỉnh sửa, enhance trên các issue ở /Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/Product/xTalent/db/review-01-dbml-cross-module-analysis.md, tất cả các enhance cần ghi chú có thông tin: 26Mar2026 để biết về thời điểm fix này:
1. G1: thêm FK, cho phép null
2. G2: piece-rate/output-based pay thì nên thêm entity mới hay bổ sung vào comp basis? tôi thiên về hướng thêm vào comp basis, bạn xem có hợp lý không? và thực hiện
3. G3: thêm bridge table link giữa time_type_code và pay element
4. G4, G5, G6, G7, G8: thực hiện như bạn đề nghị
5. G9: bỏ qua

##

hãy xem các file ở thư mục /Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/02-dbml
1. CO: core module
2. PR: payroll
3. TA: time & absence
4. TR: total rewards
Liên quan đến eligibility hãy rà soát lại các định nghĩa ở đó xem đã phù hợp chưa, và kiểm soát việc integration với các module khác ra sao, có ổn hết không nhé. 
Sau đó viết 1 guide giới thiệu về eligibility và giải pháp chúng ta đang mô hình hoá, tài liệu đặt ở /Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/02-dbml

##

hãy xem các file ở thư mục /Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/02-dbml
1. CO: core module
2. PR: payroll
3. TA: time & absence
4. TR: total rewards

Tôi cần bạn xem xét việc config các component total rewards theo country, legal entity một cách độc lập được hay không? và cách config country đã ổn thoả chưa?

So sánh với các giải pháp HR hàng đầu thì phương pháp config của chúng ta có gì khác biệt, ưu nhược điểm ra sao? và có thể cải tiến gì không?

##

Tôi đồng ý phương án Option 1 (Light Touch)** — thêm `country_code` + `legal_entity_id` optional vào 5 definition tables.
Nhưng đồng thời implement cả Option 2: Config Scope Group (Alternative) -> note rõ trên các field thêm vào để hiểu rõ
Sau đó viết thành 1 guide để giải thích chính xác phương án áp dụng ở 2 phương án, team có thể flexible áp dụng tuỳ theo giai đoạn và sau khi áp dụng full cả 2 thì sẽ có thể config tuỳ theo client? bạn thấy ý tưởng này đúng không?