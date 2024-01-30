from rest_framework import serializers
from .models import *
from acc_record.serializers import TransactionShowSerializer 
from django.contrib.auth.models import User

class AccountInfo(serializers.ModelSerializer):
    # username = serializers.SerializerMethodField()
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = Financialaccount
        exclude = ('owner', )
        # fields = (
        #     '__all__',
        #     'username'
        # )
        
    def create(self, validated_data):
        username = validated_data.pop('username')
        if User.objects.filter(username=username).exists():
            user = User.objects.get(username=username)
            instance = Financialaccount.objects.create(owner=user, **validated_data)
            return instance
        else:
            raise serializers.ValidationError("User with this username does not exist.")
    # def get_username(self, obj):
    #     user = User.objects.get(username=obj.owner)
    #     return user.username
    
class CardInfo(serializers.ModelSerializer):
    # username = serializers.SerializerMethodField()
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = Cardaccount
        exclude = ('owner', )
        # fields = (
        #     '__all__',
        # )
        
    def create(self, validated_data):
        username = validated_data.pop('username')
        user = User.objects.get(username=username)
        instance = Cardaccount.objects.create(owner=user, **validated_data)
        return instance
        
    # def get_username(self, obj):
    #     user = User.objects.get(username=obj.owner)
    #     return user.username
    
class PayInfo(serializers.ModelSerializer):
    # username = serializers.SerializerMethodField()
    username = serializers.CharField(write_only=True)
    
    class Meta:
        model = Payaccount
        exclude = ('owner', )
        # fields = (
        #     '__all__',
        # )
        
    def create(self, validated_data):
        username = validated_data.pop('username')
        user = User.objects.get(username=username)
        instance = Payaccount.objects.create(owner=user, **validated_data)
        return instance
    # def get_username(self, obj):
    #     user = User.objects.get(username=obj.owner)
    #     return user.username
    
    
        

# class AccountTrans(serializers.ModelSerializer):
#     transaction = TransactionShowSerializer(many = True, read_only = True)
    
#     class Meta:
#         model = Financialaccount
#         fields = (
#             'nickname',
#             'bankname',
#             'accountnumber',
#             'assetamount',
#             'transaction',
#         )
        
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