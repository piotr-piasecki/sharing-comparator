public with sharing class MyHTMLParser {
    public static List<String> columns;

    public MyHTMLParser(List<String> cols) {
        columns = cols;
    }

    public Table generateTable(String body) {
        return new MyHTMLParser.Table(getRows(getProcessedBody(body)));
    }

    public class Table {
        public List<Row> rows;

        public Table(List<String> tableRows) {
            this.rows = new List<Row>();

            for (String row : tableRows) {
                if (row.startsWith('<tr>') && row.endsWith('</tr>')) {
                    this.rows.add(new Row(row));
                }
            }
        }

        public Boolean equals(Object obj) {
            if (obj instanceof Table) {
                Table table = (Table) obj;
                return (this.rows == table.rows);
            }
            return false;
        }

        public Integer hashCode() {
            return this.rows != null ? 31 * this.rows.hashCode() : 0;
        }
    }

    public class Row {
        public Map<String, String> cells;

        public Row(String tableRow) {
            this.cells = new Map<String, String>();

            List<String> cellsSourceData = tableRow.substringBetween('<tr><td>','</td></tr>').split('</td><td>');

            for (Integer i = 0; i < columns.size(); i ++) {
                this.cells.put(columns.get(i), cellsSourceData.get(i));
            }
        }

        public Boolean equals(Object obj) {
            if (obj instanceof Row) {
                Row row = (Row) obj;
                return (this.cells == row.cells);
            }
            return false;
        }

        public Integer hashCode() {
            return this.cells != null ? 31 * this.cells.hashCode() : 0;
        }
    }



    private String getProcessedBody(String body) {
        return body
            .replaceAll('<!--.*?-->', '')
            .substringBetween('<table class="list" border="0" cellspacing="0" cellpadding="0">', '</table>')
            .replaceAll('Why\\?', '')
            .replaceAll('<tr.*?>', '<tr>')
            .replaceAll('<td.*?>', '<td>')
            .replaceAll('<a href="/setup.*?</a>', '')
            .replaceAll('<th.*?>', '<td>')
            .replaceAll('<a>', '<td>')
            .replaceAll('</a>', '</td>')
            .replaceAll('<a href="/', '<td>')
            .replaceAll('<td></td>', '')
            .replaceAll('</th>', '</td>')
            .replaceAll('</td></td>', '</td>')
            .replaceAll('<tr>A.*>', '')
            .replaceAll('<td><td>', '<td>')
            .replaceAll('">', '</td><td>')
            .replaceAll('\n\n', '\n')
            .replaceAll('\n\n', '\n')
            .replaceAll('\n', ';');

    }

    private List<String> getRows(String source) {
        List<String> rows = source.split(';');
        rows.remove(0);
        return rows;
    }


    public Map<String, Map<String, String>> getAsMapByKey(String key, MyHTMLParser.Table table) {
        Map<String, Map<String, String>> resultMap = new Map<String, Map<String, String>>();
        for (MyHTMLParser.Row row : table.rows) {
            resultMap.put(row.cells.get(key), row.cells);
        }
        return resultMap;
    }
}