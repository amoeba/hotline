# frozen_string_literal: true

class Response < BinData::Record
  endian :big

  uint16 :kind
  uint16 :remaining
  uint16 :n
end

class Server < BinData::Record
  endian :big

  uint32 :ip
  uint16 :port
  uint16 :n_users
  uint16 :empty # Not used

  uint8 :name_len
  string :name, read_length: :name_len

  uint8 :desc_len
  string :description, read_length: :desc_len
end
