require_relative '../test_helper'

describe Order do
  it 'can be created' do
    order = create :order
    refute_nil order.id
  end

  it 'validates presence of txn_id' do
    order = create :order, txn_id: nil
    assert_equal false, order.save
    assert_nil order.id
  end

  it 'validates uniqueness of txn_id' do
    order = create :order
    another = build :order, txn_id: order.txn_id
    assert_equal false, another.save
    assert_nil another.id
  end

  # TODO: check that all fields are required
  # property :gross, Float, required: true # 1290
  # property :currency, String, required: true # "THB"
  # property :quantity, Integer, required: true # 3
  # property :item, Enum[:ranong, :ranong_andaman, :penang], required: true # 1 for Ranong, 2 for Ranong Andaman, 3 for Penang
  # property :payer_id, String, required: true # "XSR2NSLSMU6PQ"
  # property :payment_at, Time, required: true # Time
  # property :payer_first_name, String, required: true # "FILIPP"
  # property :payer_last_name, String, required: true # "PIROZHKOV"
  # property :payer_email, String, required: true # "pirjsuka@gmail.com"
  # property :residence_country, String, required: true # "RU"
  # property :trip_date, Date, required: true # Date 2014-03-13
  # property :phone, String, required: true # "0840888888"
  # property :leader, String, required: true # "John Smith"

  it 'parses paypal data' do
    body = ["SUCCESS",
     "mc_gross=2580.00",
     "protection_eligibility=Eligible",
     "address_status=unconfirmed",
     "payer_id=XSR2NSLSMU6PQ",
     "tax=0.00",
     "address_street=Nalichnaya+3/21",
     "payment_date=02%3A04%3A28+Apr+14%2C+2014+PDT",
     "payment_status=Completed",
     "charset=windows-874",
     "address_zip=199106",
     "first_name=FILIPP",
     "mc_fee=12.06",
     "address_country_code=RU",
     "address_name=PIROZHKOV+FILIPP",
     "custom=",
     "payer_status=verified",
     "business=keinnariin%40gmail.com",
     "address_country=Russia",
     "address_city=Saint-Petersburg",
     "quantity=2",
     "payer_email=pirjsuka%40gmail.com",
     "txn_id=985050571X9491404",
     "payment_type=instant",
     "last_name=PIROZHKOV",
     "address_state=-",
     "receiver_email=keinnariin%40gmail.com",
     "payment_fee=",
     "receiver_id=KHGTN6Q5JVNV8",
     "txn_type=web_accept",
     "item_name=Visa+run+Ranong+04/16/2014",
     "mc_currency=THB",
     "item_number=1",
     "residence_country=RU",
     "handling_amount=0.00",
     "transaction_subject=",
     "payment_gross=",
     "shipping=0.00"
    ]

    order = Order.parse_paypal body, { date: I18n.l(Date.today + 2), phone: '23423424234', name: "Pqqq Aaaa" }
    refute_nil order.id
  end

  # TODO: check all possible fails
  it '' do
    # fail FailedPayment, :payment_gate_fail unless result == SUCCESS
    # fail FailedPaymentForRefund, I18n.t('fails.no_such_item') unless (1..3).include? data[:item_number]
    # fail FailedPaymentForRefund, I18n.t('fails.not_thb') unless data[:mc_currency] == THB
    # fail FailedPaymentForRefund, I18n.t('fails.gross_mismatch') unless data[:mc_gross] == data[:quantity] * PRICES[data[:item_number]]
  end
end
