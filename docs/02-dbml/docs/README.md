# 02-dbml/docs — Reference Documents

Thư mục này chứa tài liệu giải thích thiết kế schema, data flow, và usage guide cho các sub-module.

## Tài liệu hiện có

| File | Nội dung |
|------|---------|
| [absence-data-flow-guide.md](./absence-data-flow-guide.md) | Data flow, init order, model usage, và phân nhánh Policy vs Rule Engine cho Absence sub-module |
| [absence-sample-data.json](./absence-sample-data.json) | Sample data graph JSON: type → class → rule → instant → request. Dùng với [JSON Crack](https://jsoncrack.com) để visualize |

## Cách dùng JSON Crack

1. Mở https://jsoncrack.com
2. Paste nội dung từ `absence-sample-data.json`
3. Dùng "Visualize" để xem graph quan hệ giữa các entity
4. Các ID reference (`employee_id`, `class_id`, `rule_id`...) là các edge trong graph

## Cross-references

- Schema: [../TA/TA-database-design-v5.dbml](../TA/TA-database-design-v5.dbml)
- Changelog: [../CHANGELOG.md](../CHANGELOG.md)
- Domain: [../../01-modules/TA/03.domain/absence/glossary.md](../../01-modules/TA/03.domain/absence/glossary.md)
- Bounded Contexts: [../../01-modules/TA/03.domain/bounded-contexts.md](../../01-modules/TA/03.domain/bounded-contexts.md)
