from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .serializers import *
from datetime import date
# Create your views here.


class TransactionAll(ModelViewSet):
    # queryset = Transaction.objects.all()
    serializer_class = TransactionAllSerializer
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            # Admin sees all instances
            return Transaction.objects.all()
        else:
            # Regular user Can't use
            return Transaction.objects.none()
class InvestmentAll(ModelViewSet):
    # queryset = Investment.objects.all()
    serializer_class = InvestmentSerailizer  
    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            # Admin sees all instances
            return Investment.objects.all()
        else:
            # Regular user Can't use
            return Investment.objects.none()
    
class Hashtag(ModelViewSet):
    queryset = Tag_Category.objects.all()
    serializer_class = TagSerializer
    
class HashTagControlAPI(APIView):
    def get(self, request, formatter=None):
        Tags = Tag_Category.objects.all()
        # 미관련 태그 삭제
        for tag in Tags:
            if len(TagSerializer(tag).data['relate_transaction'])==0:
                tag.delete()
        Tags = Tag_Category.objects.all()
        serializer = TagSerializer(Tags, many=True, context={"request": request})
        return Response(serializer.data)
    
class MonthlyTransaction(APIView):
    def get(self, request, year, month, format=None):
        user = self.request.user
        account = Transaction.objects.filter(transaction_time__year=year, transaction_time__month=month).order_by('transaction_time')
        # account = Transaction.objects.filter(transaction_from=accountname)
        # account = Transaction.objects.filter(transaction_from_str=accountname)
        serializer = TransactionAllSerializer(account, many=True, context={"request": request})
        return Response(serializer.data)
    
class YearlyTransaction(APIView):
    def get(self, request, year, format=None):
        user = self.request.user
        account = Transaction.objects.filter(transaction_time__year=year).order_by('transaction_time')
        # account = Transaction.objects.filter(transaction_from=accountname)
        # account = Transaction.objects.filter(transaction_from_str=accountname)
        serializer = TransactionAllSerializer(account, many=True, context={"request": request})
        return Response(serializer.data)

class DateRangeTransaction(APIView):
    def get(self, request, format=None):
        user = self.request.user
        startdate = request.GET.get('start', '2015-01-01')
        enddate = request.GET.get('end', date.today())
        account = Transaction.objects.filter(transaction_time__range=[startdate, enddate]).order_by('transaction_time')
        # account = Transaction.objects.filter(transaction_from=accountname)
        # account = Transaction.objects.filter(transaction_from_str=accountname)
        serializer = TransactionAllSerializer(account, many=True, context={"request": request})
        return Response(serializer.data)
    
    
class TransactionBasics(APIView):
    def get(self, request, accountnumber, format=None):
        account = Transaction.objects.filter(transaction_from=accountnumber).order_by('transaction_time')
        # account = Transaction.objects.filter(transaction_from=accountname)
        # account = Transaction.objects.filter(transaction_from_str=accountname)
        serializer = TransactionAllSerializer(account, many=True, context={"request": request})
        return Response(serializer.data)
    def post(self, request, accountnumber, format=None):
        # uses the double asterisk (**) syntax to unpack the dictionary of data
        data=[]
        data = dict(**request.data)
        keys = list(data.keys())
        for key in keys:
            data[key] = data[key][0]
            if data[key] == "":
                del data[key]
        check_transaction = Transaction.objects.filter(**data)
        if not check_transaction.exists():
            corpname = Company_Category_Correlation.objects.filter(company_accountname = request.data['transaction_to_name'])
            if len(corpname) == 0:
                relation_data = {'company_accountname':request.data['transaction_to_name'],'company_commonname':request.data['transaction_to_name']}
                preworkserializer = CompanyCorrelationSerializer(data=relation_data)
                if(preworkserializer.is_valid()):
                    try:
                        preworkserializer.save()
                    except:
                        print("already exist corpname")
            post_serializer = TransactionAllSerializer(data=request.data)
            if(post_serializer.is_valid()):
                post_serializer.save()
                return Response(post_serializer.data, status=status.HTTP_201_CREATED) #client에게 JSON response 전달
            else:
                return Response(post_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            print("already exist transaction")
            return Response(status=status.HTTP_204_NO_CONTENT)
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
        if contest_list != None: 
            update_content = TransactionAllSerializer(contest_list, data=request.data)
            if update_content.is_valid():
                update_content.save()
                return Response(status=status.HTTP_204_NO_CONTENT)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        
# class Category(ModelViewSet):
#     queryset = Main_Category.objects.all()
#     serializer_class = MoneyCategorySerializer
# class Company_Nickname(ModelViewSet):
#     queryset = Company_Category_Correlation.objects.all()
#     serializer_class = CompanyCorrelationSerializer