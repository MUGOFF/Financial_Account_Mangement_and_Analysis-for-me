from rest_framework import serializers
from .models import *
from acc_record.serializers import TransactionAccountSerializer 

class AccountInfo(serializers.ModelSerializer):
    class Meta:
        model = Financialaccount
        fields = (
            'nickname',
            'bankname',
            'accountnumber',
            'account_type',
            'assetamount',
            'description',
        )
        
class CardInfo(serializers.ModelSerializer):
    class Meta:
        model = Cardaccount
        fields = (
            'nickname',
            'corpname',
            'cardnumber',
            'card_type',
            'bankconnect',
            'expiredmonth',
            'description',
        )
        
class PayInfo(serializers.ModelSerializer):
    class Meta:
        model = Payaccount
        fields = (
            'id',
            'nickname',
            'corpname',
            'assetamount',
            'description',
            'bankconnection',
            'cardconnection',
        )

class AccountTrans(serializers.ModelSerializer):
    transaction = TransactionAccountSerializer(many = True, read_only = True)
    
    class Meta:
        model = Financialaccount
        fields = (
            'nickname',
            'bankname',
            'accountnumber',
            'assetamount',
            'transaction',
        )