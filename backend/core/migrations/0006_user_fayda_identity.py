from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("core", "0005_integrity_constraints"),
    ]

    operations = [
        migrations.AddField(
            model_name="user",
            name="date_of_birth",
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="user",
            name="fayda_number",
            field=models.CharField(
                blank=True,
                db_index=True,
                max_length=20,
                null=True,
                unique=True,
            ),
        ),
        migrations.AddField(
            model_name="user",
            name="gender",
            field=models.CharField(
                blank=True,
                choices=[("M", "Male"), ("F", "Female")],
                default="",
                max_length=1,
            ),
        ),
        migrations.AddField(
            model_name="user",
            name="legal_name",
            field=models.CharField(blank=True, default="", max_length=255),
        ),
    ]
