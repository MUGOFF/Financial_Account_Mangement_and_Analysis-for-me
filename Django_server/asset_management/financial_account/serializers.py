from rest_framework import serializers
from .models import *
from acc_record.serializers import TransactionShowSerializer 
from django.contrib.auth.models import User

class AccountInfo(serializers.ModelSerializer):
    # username = serializers.SerializerMethodField()
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = Financialaccount
        # fields = (
        #     '__all__',
        #     'username'
        # )
        exclude = ('owner', )
        
    # def get_username(self, obj):
    #     user = User.objects.get(username=obj.owner)
    #     return user.username
    
    def create(self, validated_data):
        username = validated_data.pop('username')
        if User.objects.filter(username=username).exists():
            user = User.objects.get(username=username)
            instance = Financialaccount.objects.create(owner=user, **validated_data)
            return instance
        else:
            raise serializers.ValidationError("User with this username does not exist.")
class CardInfo(serializers.ModelSerializer):
    # username = serializers.SerializerMethodField()
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = Cardaccount
        # fields = (
        #     '__all__',
        # )
        exclude = ('owner', )
        
    # def get_username(self, obj):
    #     user = User.objects.get(username=obj.owner)
    #     return user.username
    
    def create(self, validated_data):
        username = validated_data.pop('username')
        user = User.objects.get(username=username)
        instance = Cardaccount.objects.create(owner=user, **validated_data)
        return instance
class PayInfo(serializers.ModelSerializer):
    # username = serializers.SerializerMethodField()
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = Payaccount
        # fields = (
        #     '__all__',
        # )
        exclude = ('owner', )
        
    # def get_username(self, obj):
    #     user = User.objects.get(username=obj.owner)
    #     return user.username
    
    def create(self, validated_data):
        username = validated_data.pop('username')
        user = User.objects.get(username=username)
        instance = Payaccount.objects.create(owner=user, **validated_data)
        return instance
    
# class AccountInfo(serializers.ModelSerializer):
#     class Meta:
#         model = Financialaccount
#         fields = (
#             'nickname',
#             'bankname',
#             'accountnumber',
#             'account_type',
#             'account_founddate',
#             'account_expireddate',
#             'assetamount',
#             'description',
#         )
        
# class CardInfo(serializers.ModelSerializer):
#     class Meta:
#         model = Cardaccount
#         fields = (
#             'nickname',
#             'corpname',
#             'cardnumber',
#             'card_type',
#             'bankconnect',
#             'expiredmonth',
#             'description',
#         )
        

class AccountTrans(serializers.ModelSerializer):
    transaction = TransactionShowSerializer(many = True, read_only = True)
    
    class Meta:
        model = Financialaccount
        fields = (
            'nickname',
            'bankname',
            'accountnumber',
            'assetamount',
            'transaction',
        )