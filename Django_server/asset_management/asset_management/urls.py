"""asset_management URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from . import views
from .views import ApiMapRouter
from django.conf.urls.static import static
from django.conf import settings

homerouter = ApiMapRouter()
# router = DefaultRouter()
# router.register('Account_record', include('financial_account.urls'), basename='Account_record')
# router.register('Account_management', include('acc_record.urls'), basename='Account_management')
urlpatterns = [
    path('', include(homerouter.urls), name='api-map'),
    path('admin/', admin.site.urls),
    path('auth/', include('djoser.urls'),name='auth'),
    path('auth/', include('djoser.urls.authtoken')),
    path('auth/', include('djoser.urls.jwt')),    
    path('auth/valdiation/', views.CheckUsernameValidation.as_view()),    
    path('auth/valdiation/token/', views.CheckTokenValidation.as_view()),    
    # path('api/', include('financial_company.urls')),
    path('api/v1/', include('financial_account.urls')),
    path('api/v1/', include('acc_record.urls')),
    path('api/v1/', include('book.urls')),
    path('api/v1/', include('user_personal_setting.urls')),
    # path('', views.HomeView, name='home'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

