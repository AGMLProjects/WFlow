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

void insertNode(Node **head, SensorInput data)
{
    Node *newNode = createNode(data);

    if(*head == NULL)
    {
        *head = newNode;
    }
    else
    {
        Node *temp = *head;

        while(temp->next != NULL)
        {
            temp = temp->next;
        }

        temp->next = newNode;
    }
}

SensorInput popNode(Node **head)
{
    if (*head == NULL) {
        // Handle empty list (optional)
        // You might want to return a special value or handle the case differently
#ifdef FLO
        SensorInput empty = {.seconds = 0};
        return empty;
#elif defined(LEV)
        SensorInput empty = {.timestamp = 0};
        return empty;
#elif defined(HEA)
        SensorInput empty = {.start = 0, .end = 0, .ready = false};
        return empty;
#else
        return 0;
#endif
    }

    Node *temp = *head; // Store the current head node
    SensorInput data = temp->data; // Get the data from the head node

    *head = (*head)->next; // Update the head pointer to the next node

    free(temp); // Free the memory of the popped node
    return data; // Return the data from the popped node
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
