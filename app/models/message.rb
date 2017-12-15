class Message < ApplicationRecord
  MW = {
    password: "185247",
    userid: "JI1153",
    submit_url: "http://101.251.214.153:8901/MWGate/wmgw.asmx",
  }
  MWVOICE = {
    password: "651232",
    userid: "YY0205",
    submit_url: "http://61.145.229.28:5001/voiceprepose",
    pt_tmpl_id: "200047",
  }
  def self.send_verification_code(phone, request_ip, is_voice = false, pre = nil )
    send_message_count = $redis.incrby("send_message_count_#{phone}", 1)
    ip_send_message_count = $redis.incrby("ip_send_message_count_#{request_ip}", 1)
    $redis.expire("send_message_count_#{phone}", 24 * 3600)
    $redis.expire("ip_send_message_count_#{request_ip}", 24 * 3600)
    if send_message_count < 10 && ip_send_message_count < 50
      code = "%06d" % rand(999999)
      if SYSTEMCONFIG[:test]
        code = "111111"
      end
      if pre
        $cache.set("#{pre}_#{phone}", code, 5 * 60)
      else
        $cache.set(phone, code, 5 * 60) #短信验证码有效期10分钟
      end
      #暂时全部发送语音验证码
      # is_voice = true
      unless is_voice
        Message.create(psz_mobis: phone, psz_msg: "您好，感谢关注钻联科技，您的手机验证码是：#{code}，请妥善保管！", i_mobi_count: 1, request_ip: request_ip, is_voice: false)
      else
        Message.create(psz_mobis: phone, psz_msg:  code, i_mobi_count: 1, request_ip: request_ip, is_voice: true, psz_sub_port: "125909888778")
      end
    else
      return false
    end
  end

  after_create :send_message
  private
  def send_message
    conn = Faraday.new
    unless self.is_voice
      res = conn.post(Message::MW[:submit_url]+"/MongateSendSubmit", {userId: Message::MW[:userid],
        password: Message::MW[:password],
        pszMobis: self.psz_mobis,
        pszMsg: self.psz_msg,
        iMobiCount: self.i_mobi_count,
        pszSubPort: self.psz_sub_port,
        MsgId: self.id,
      })
    else
      res = conn.post(Message::MWVOICE[:submit_url]+"/MongateSendSubmit", {userId: Message::MWVOICE[:userid],
        password: Message::MWVOICE[:password],
        pszMobis: self.psz_mobis,
        pszMsg: self.psz_msg,
        iMobiCount: self.i_mobi_count,
        pszSubPort: self.psz_sub_port,
        MsgId: self.id,
        PtTmplId: Message::MWVOICE[:pt_tmpl_id],
        msgType: "1"
      })
    end
    Rails.logger.info(res.body)
    doc =  REXML::Document.new(res.body)
    self.update(response_code: doc.root.text)
  end
end
