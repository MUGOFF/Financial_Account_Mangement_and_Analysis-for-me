from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .serializers import *

# Create your views here.
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
class AccountBase(ModelViewSet):
    queryset = Financialaccount.objects.all()
    serializer_class = AccountInfo
class CardBase(ModelViewSet):
    queryset = Cardaccount.objects.all()
    serializer_class = CardInfo
class PayBase(ModelViewSet):
    queryset = Payaccount.objects.all()
    serializer_class = PayInfo

class Account_Book_Bookmark(APIView):
    # 전 기록 추출
    def get(self, request, format=None):
        # account = Transaction.objects.filter(account=accountname)
        account = Financialaccount.objects.all()
        serializer = AccountTrans(account, many=True, context={"request": request})
        return Response(serializer.data)