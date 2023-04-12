from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .serializers import *
# Create your views here.


class TransactionAll(ModelViewSet):
    queryset = Transaction.objects.all()
    serializer_class = TransactionAllSerializer
class Category(ModelViewSet):
    queryset = Main_Category.objects.all()
    serializer_class = MoneyCategorySerializer
class Company_Nickname(ModelViewSet):
    queryset = Company_Category_Correlation.objects.all()
    serializer_class = CompanyCorrelationSerializer
    
    
class TransactionBasics(APIView):
    def get(self, request, accountnumber, format=None):
        account = Transaction.objects.filter(transaction_from=accountnumber).order_by('transaction_time')
        # account = Transaction.objects.filter(transaction_from=accountname)
        # account = Transaction.objects.filter(transaction_from_str=accountname)
        serializer = TransactionAllSerializer(account, many=True, context={"request": request})
        return Response(serializer.data)
    def post(self, request, accountnumber, format=None):
        corpname = Company_Category_Correlation.objects.filter(company_accountname = request.data['transaction_to_name'])
        if len(corpname) == 0:
            relation_data = {'company_accountname':request.data['transaction_to_name'],'company_commonname':request.data['transaction_to_name']}
            preworkserializer = CompanyCorrelationSerializer(data=relation_data)
            if(preworkserializer.is_valid()):
                try:
                    preworkserializer.save()
                except:
                    print("already exist")
        post_serializer = TransactionAllSerializer(data=request.data)
        if(post_serializer.is_valid()):
            post_serializer.save()
            return Response(post_serializer.data, status=status.HTTP_201_CREATED) #client에게 JSON response 전달
        else:
            return Response(post_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    def delete(self,request, accountnumber, formatter=None):
        id = int(request.GET.get('id',1))
        contest_list = Transaction.objects.filter(transaction_from=accountnumber) & Transaction.objects.filter(id = id)
        if contest_list != None: 
            contest_list.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)
    def put(self,request, accountnumber, formatters=None):
        id = int(request.GET.get('id',1))
        contest_list = Transaction.objects.filter(transaction_from=accountnumber) & Transaction.objects.filter(id = id)
        print(request.data)
        if contest_list != None: 
            update_content = TransactionAllSerializer(contest_list, data=request.data)
            if update_content.is_valid():
                update_content.save()
                return Response(status=status.HTTP_204_NO_CONTENT)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)