#include <stdio.h>
#include <stdlib.h>

#include "list.h"

Node* createNode(SensorInput data)
{
    Node *newNode = (Node *)malloc(sizeof(Node));

    newNode->data = data;
    newNode->next = NULL;

    return newNode;
}

void insertNode(Node *head, SensorInput data)
{
    Node *newNode = createNode(data);

    if(head == NULL)
    {
        head = newNode;
    }
    else
    {
        Node *temp = head;

        while(temp->next != NULL)
        {
            temp = temp->next;
        }

        temp->next = newNode;
    }
}

SensorInput popNode(Node *head)
{
    Node *next = head->next;
    SensorInput data = head->data;

    free(head);
    head = next;
    return data;
}

bool available_data(Node *head)
{
    if(head != NULL)
    {
        return true;
    }
    else
    {
        return false;
    }
}
