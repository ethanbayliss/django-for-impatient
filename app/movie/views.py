'''Movie app views'''

from django.shortcuts import render
from django.http import HttpResponse

from .models import Movie

def home(request):
    '''Home page'''
    search_term = request.GET.get('searchMovie')
    movies = Movie.objects.all()
    return render(request, 'home.html', {'searchTerm': search_term, 'movies': movies})

def about():
    '''About page'''
    return HttpResponse('<h1>about</h1')

def signup(request):
    '''Signup page. Takes in email and renders successful signup page for user'''
    email = request.GET.get('email')
    return render(request, 'signup.html', {'email': email})
