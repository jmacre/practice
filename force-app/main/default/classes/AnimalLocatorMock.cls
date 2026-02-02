@isTest
global class AnimalLocatorMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        // Parse id from endpoint: .../animals/{id}
        String endpoint = request.getEndpoint();
        String idStr = endpoint != null && endpoint.contains('/animals/') 
            ? endpoint.substringAfterLast('/animals/')
            : null;

        // Build a simple mapping for a few ids - FIXED JSON STRUCTURE
        Map<Integer, String> animalsById = new Map<Integer, String>{
            1 => '{"animal":{"id":1,"name":"majestic badger"}}',
            2 => '{"animal":{"id":2,"name":"fluffy bunny"}}',
            3 => '{"animal":{"id":3,"name":"scary bear"}}',
            4 => '{"animal":{"id":4,"name":"chicken"}}',
            5 => '{"animal":{"id":5,"name":"mighty moose"}}'
        };

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');

        Integer idVal;
        try {
            idVal = idStr == null ? null : Integer.valueOf(idStr);
        } catch (Exception e) {
            idVal = null;
        }

        if (idVal != null && animalsById.containsKey(idVal)) {
            response.setStatusCode(200);
            response.setBody(animalsById.get(idVal));
        } else {
            response.setStatusCode(404);
            response.setBody('{"error":"Animal not found"}');
        }
        return response;
    }
}