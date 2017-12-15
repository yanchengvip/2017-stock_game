    rails g scaffold sale_diamond name is_published:boolean "min_size:decimal{5,4}" "max_size:decimal{5,4}"  exchange_name  exchange_code idex_trading_volume:integer rap_trading_volume:integer color  clarity "change_price:decimal{10,2}"  change_price_persent "price:decimal{10,2}" "current_price:decimal{10,2}" "price:decimal{10,2}" "current_price:decimal{10,2}" "opening_price:decimal{10,2}"


rails g scaffold user   phone  encrypted_password current_sign_in_at:datetime last_sign_in_at:datetime  current_sign_in_ip  last_sign_in_ip province openid nickname sex:integer city country  headimgurl   unionid


 rails g scaffold message  psz_sub_port  i_mobi_count:integer psz_msg:text psz_mobis:text request_ip channel_name


rails g scaffold sale_diamond_history_price sale_diamond_id:integer  "price:decimal{10,2}" date_time:datetime day


rails g scaffold diamond_trade sale_diamond_id:integer
