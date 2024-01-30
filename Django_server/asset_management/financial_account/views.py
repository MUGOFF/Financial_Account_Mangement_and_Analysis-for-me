from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .serializers import *

# Create your views here.
class AccountBase(ModelViewSet):
    # queryset = Financialaccount.objects.all()
    serializer_class = AccountInfo
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            # Admin sees all instances
            return Financialaccount.objects.all()
        else:
            # Regular user sees only their instances
            return Financialaccount.objects.filter(owner=user)
        
class CardBase(ModelViewSet):
    # queryset = Cardaccount.objects.all()
    serializer_class = CardInfo
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            # Admin sees all instances
            return Cardaccount.objects.all()
        else:
            # Regular user sees only their instances
            return Cardaccount.objects.filter(owner=user)
        
class PayBase(ModelViewSet):
    # queryset = Payaccount.objects.all()
    serializer_class = PayInfo
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            # Admin sees all instances
            return Payaccount.objects.all()
        else:
            # Regular user sees only their instances
            return Payaccount.objects.filter(owner=user)

# class Account_Book_Bookmark(APIView):
#     # 전 기록 추출
#     def get(self, request, format=None):
#         # account = Transaction.objects.filter(account=accountname)
#         account = Financialaccount.objects.all()
#         serializer = AccountTrans(account, many=True, context={"request": request})
#         return Response(serializer.data)
    
        # ismany = request.GET.get('many', True)
        # if ismany:
        #     serializer = AccountInfo(data= request.data, many=True)
        # else:
    # def get(self, request, format=None):
    #     account = Financialaccount.objects.all()
    #     serializer = AccountInfo(account, many=True, context={"request": request})
    #     return Response(serializer.data)
    # def post(self, request, format=None):
    #     serializer = AccountInfo(data= request.data)
    #     if serializer.is_valid():
    #         serializer.save()
    #         return Response(serializer.data, status=status.HTTP_201_CREATED)
    #     else:
    #         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    # def put(self,)