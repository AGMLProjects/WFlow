from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from .models import TestObject
from .serializers import TestObjectSerializer


@api_view(['GET', 'POST'])
def testobject_list(request, format=None):

    if request.method == 'GET':
        # get all the testobjects
        testObjects = TestObject.objects.all()
        # serialize them
        serializer = TestObjectSerializer(testObjects, many=True)
        # return json
        return Response(serializer.data)

    elif request.method == 'POST':
        # deserialize the request data
        serializer = TestObjectSerializer(data=request.data)
        # check if data is valid format
        if serializer.is_valid():
            serializer.save()
            # return json
            return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['GET', 'PUT', 'DELETE'])
def testobject_detail(request, id, format=None):

    try:
        testobject = TestObject.objects.get(pk=id)
    except TestObject.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = TestObjectSerializer(testobject)
        return Response(serializer.data)

    elif request.method == 'PUT':
        serializer = TestObjectSerializer(testobject, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        testobject.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
