from django.apps import apps
from acc_record.urls import router as record_router 
from financial_account.urls import router as account_router 
from rest_framework.response import Response
from rest_framework.reverse import reverse
from collections import OrderedDict
from django.urls import NoReverseMatch
from rest_framework.routers import DefaultRouter, APIRootView
from rest_framework.permissions import IsAdminUser

# Create your views here.
# def HomeView(request):
#     return redirect('admin/')

# class ApiRootMapView(APIRootView):
#     """
#     This appears where the docstring goes!
#     """
class ApiRootMapView(APIRootView):
    """
    API route full mapping
    """
    permission_classes = [IsAdminUser]
    
    def get(self, request, *args, **kwargs):
        # Return a plain {"name": "hyperlink"} response.
        router_map = OrderedDict()
        namespace = request.resolver_match.namespace
        for appkey, app_name in self.api_root_dict.items():
            ret = OrderedDict()
            for key, url_name in app_name.items():
                if namespace:
                    url_name = namespace + ':' + url_name
                try:
                    ret[key] = reverse(
                        url_name,
                        args=args,
                        kwargs=kwargs,
                        request=request,
                        format=kwargs.get('format')
                    )
                except NoReverseMatch:
                    # Don't bail out if eg. no list routes exist, only detail routes.
                    continue
            router_map[appkey] = ret
        return Response(router_map)
    

class ApiMapRouter(DefaultRouter):
    APIRootView = ApiRootMapView
    
    def get_api_root_view(self, api_urls=None):
        """
        Return a basic root view.
        """
        list_name = self.routes[0].name
        api_root_dict = OrderedDict()
        #계좌 내역 라우터
        api_root_dict['account_record'] = OrderedDict()
        for prefix, viewset, basename in record_router.registry:
            api_root_dict['account_record'][prefix] = list_name.format(basename=basename)
        #계좌 관리 라우터
        api_root_dict['account_management'] = OrderedDict()
        for prefix, viewset, basename in account_router.registry:
            api_root_dict['account_management'][prefix] = list_name.format(basename=basename)
        return self.APIRootView.as_view(api_root_dict=api_root_dict)
    
# router.register(r'items', ItemsViewSet)
# class ThisWillBeTheApiTitleView(routers.APIRootView):
#     """
#     This appears where the docstring goes!
#     """
#     pass


# class DocumentedRouter(routers.DefaultRouter):
#     APIRootView = ThisWillBeTheApiTitleView


# router = DocumentedRouter()
# router.register(r'items', ItemsViewSet)

from rest_framework.permissions import AllowAny
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
from rest_framework import status 
from rest_framework.views import APIView

class CheckUsernameValidation(APIView):
    permission_classes = [AllowAny]
    def get(self, request, format=None):
        username = request.GET.get('username')
        user = User.objects.filter(username = username)
        if user:
            return Response(status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(status=status.HTTP_204_NO_CONTENT)
class CheckTokenValidation(APIView):
    permission_classes = [AllowAny]
    def get(self, request, format=None):
        key = request.GET.get('token')
        token = Token.objects.filter(key = key)
        if token:
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            return Response(status=status.HTTP_404_NOT_FOUND)