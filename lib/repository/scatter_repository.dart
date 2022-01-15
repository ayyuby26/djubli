import 'dart:convert';
import 'package:djubli/model/car_model.dart';

class Repository {
  List nutrient(List<CarModel> data) {
    var dataBJ = [];
    for (var e in data) {
      dataBJ.add([
        int.parse(e.purchase[0].purchaseDate.split("-")[1]),
        e.price.substring(0, e.price.length - 6),
        e.usedFrom,
        e.brandName,
        e.groupModelName,
        e.modelName,
        e.exteriorColorId,
        e.km,
      ]);
    }
    return dataBJ;
  }

  highlightPoint(int index) {
    return """
    var delayInMilliseconds = 2000; //1 second
    setTimeout(function() { 
          chart.dispatchAction({
            type: 'highlight',
            seriesIndex: 0,
            dataIndex: $index
          });
        
          chart.dispatchAction({
            type: 'showTip',
            seriesIndex: 0,
            dataIndex: $index
          });
    }, delayInMilliseconds); 
    """;
  }

  String extraScript(List<CarModel> data) {
    var result = '';

    const schema = [
      {"name": "purchaseDate", "index": 0, "text": 'Tanggal Pembelian'},
      {"name": "price", "index": 1, "text": 'Harga'},
      {"name": "usedFrom", "index": 2, "text": 'Tahun'},
      {"name": "brandName", "index": 3, "text": 'Merek'},
      {"name": "groupModelName", "index": 4, "text": 'Grup'},
      {"name": "modelName", "index": 5, "text": 'Model'},
      {"name": "exteriorColorId", "index": 6, "text": 'ID warna'},
      {"name": "km", "index": 7, "text": 'KM'},
    ];

    const itemStyle = {
      "opacity": 0.8,
      "shadowBlur": 10,
      "shadowOffsetX": 0,
      "shadowOffsetY": 0,
      "shadowColor": 'rgba(0,0,0,0.3)',
    };

    const func = """
      chart.on('click', (params) => {
          Messager.postMessage(params.value[1]);
      });""";

    final dataBJ = nutrient(data);

    result += func;
    result += "const itemStyle = ${json.encode(itemStyle)};";
    result += "const schema = ${json.encode(schema)};";
    result += "const dataBJ = ${json.encode(dataBJ)};";

    return result;
  }

// =============================================

  String get optionData {
    return '''
{
    color: ['#dd4444', '#fec42c', '#80F1BE'
    ],
    legend: {
      top: 10,
      data: ['Mobil'],
      textStyle: {
        fontSize: 16
      }
    },
    grid: {
        left: '11%',
        right: '18%',
        top: '13%',
        bottom: '10%'
    },
    tooltip: {
        backgroundColor: 'rgba(255, 255, 255, 0.7)',
        formatter: function (param) {
            var value = param.value;
            // prettier-ignore
            return '<div style="border-bottom: 1px solid rgba(255,255,255,.3); font-size: 18px;padding-bottom: 7px;margin-bottom: 7px">'
            + param.seriesName+', Laku Tahun: ' + value[0]
            + '</div>'
            + schema[1].text + '：' + value[1] + '<br>'
            + schema[2].text + '：' + value[2] + '<br>'
            + schema[3].text + '：' + value[3] + '<br>'
            + schema[4].text + '：' + value[4] + '<br>'
            + schema[5].text + '：' + value[5] + '<br>'
            + schema[6].text + '：' + value[6] + '<br>';
        }
    },
    xAxis: {
        type: 'value',
        name: 'Waktu',
        nameGap: 16,
        nameTextStyle: {
          fontSize: 16
        },
        max: 12,
        splitLine: {
          show: false
        }
    },
    yAxis: {
        type: 'value',
        name: 'Harga',
        nameLocation: 'end',
        nameGap: 20,
        nameTextStyle: {
            fontSize: 16
        },
        splitLine: {
            show: false
        }
    },
    series: [
        {
            name: 'Mobil',
            data: dataBJ,
            type: 'scatter',
            itemStyle: itemStyle,
            symbolSize: function (value) {
                return value[1] / 8;
            }
        },
    ]
}
        ''';
  }
}
