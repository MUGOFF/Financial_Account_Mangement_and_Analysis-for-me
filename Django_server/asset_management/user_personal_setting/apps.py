from django.apps import AppConfig


class UserPersonalSettingConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'user_personal_setting'
    
    def ready(self):
        import user_personal_setting.signals
