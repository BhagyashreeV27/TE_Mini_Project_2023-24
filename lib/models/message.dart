class Message {
  Message({
    required this.toid,
    required this.msg,
    required this.fromid,
    required this.read,
    required this.type,
    required this.sent,
  });
  late final String toid;
  late final String msg;
  late final String fromid;
  late final String read;
  late final Type type;
  late final String sent;
  
  Message.fromJson(Map<String, dynamic> json){
    toid = json['toid'].toString();
    msg = json['msg'].toString();
    fromid = json['fromid'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toid'] = toid;
    data['msg'] = msg;
    data['fromid'] = fromid;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type{text,image}