import 'package:flutter/widgets.dart';
import 'package:lyrics_reader/lyric_parser/lyrics_parse.dart';
import 'package:lyrics_reader/lyrics_log.dart';
import 'package:lyrics_reader/lyrics_reader_model.dart';

///
class ParserQrc extends LyricsParse{

  RegExp advancedPattern = RegExp(r"""\[\d+,\d+]""");
  RegExp qrcPattern = RegExp(r"""\((\d+,\d+)\)""");

  RegExp advancedValuePattern = RegExp(r"(?<=\[)\d*,\d*(?=\])");

  ParserQrc(String lyric) : super(lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain:true}) {
    lyric =
        RegExp(r"""(?<=LyricContent=")[\s\S]*(?="/>)""").stringMatch(lyric) ??
            lyric;
    //读每一行
    var lines = lyric.split("\n");
    if (lines.isEmpty) {
      LyricsLog.logD("未解析到歌词");
      return [];
    }
    List<LyricsLineModel> lineList = [];
    lines.forEach((line) {
      //匹配time
      var time = advancedPattern.stringMatch(line);
      if (time == null) {
        //没有匹配到直接返回
        //TODO 歌曲相关信息暂不处理
        LyricsLog.logD("忽略未匹配到Time：$line");
        return;
      }
      //转时间戳
      var ts = int.parse(
          advancedValuePattern.stringMatch(time)?.split(",")[0] ?? "0");
      //移除time，拿到真实歌词
      var realLyrics = line.replaceFirst(advancedPattern, "");
      LyricsLog.logD("匹配time:$time($ts) 真实歌词：$realLyrics");
      var lineModel = LyricsLineModel()
        ..mainText = realLyrics.replaceAll(qrcPattern, "")
        ..startTime = ts;
      lineList.add(lineModel);
    });
    return lineList;
  }

  @override
  bool isOK() {
    return lyric.contains("LyricContent=") || advancedPattern.stringMatch(lyric)!=null;
  }
}