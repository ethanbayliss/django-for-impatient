from unittest.util import _MAX_LENGTH
from django.db import models

class Movie(models.Model):
    title       = models.CharField(max_length=255)
    description = models.CharField(max_length=255)
    image       = models.ImageField(upload_to='movie/images/')
    url         = models.URLField(blank=True)
