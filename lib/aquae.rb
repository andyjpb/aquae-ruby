require 'aquae/version'
require 'concurrent'

module Aquae
  # Pipe - Observable TLS-secured channel between nodes, handling framing
  #   send
  #   subscribe
  # 
  # PipeObserver
  #   converse
  # 
  def get_signed_identity server, identity 
  end
   
  def get_consent query, signed_identity
  end

  def match_identity signed_query, query_plan, answering_node
    required_fields = query_plan.required_identity_fields
    loop do
      redacted_identity = signed_identity.redact_to(required_fields)
      match_responses = answering_node.prepare_query(signed_query, redacted_identity)
      break if match_responses.all? &:complete
      required_fields += match_responses.map(&:extra_fields).flatten 
    end
  end

  def do_query 
    get_choice
    resolve_query_plan
    get_identity_data

    scope = 
    identity_bridge = @connections.get_node(query_plan.identity_bridge)
    signed_identity = identity_bridge.sign_identity_data(identity)

    consent_server = @connections.get_node(query_plan.consent_server)
    signed_scope = consent_server.sign_scope(query)

    answering_node = @connections.get_node(query_plan.answering_node)
    match_identity(signed_query, query_plan, answering_node)
    
    answer = answering_node.execute_query(query)
  end

  def 
end

class Node
  def initialize pipe
    @pipe = pipe
  end

  def sign_identity_data identity, nodes
    identity.on_success {|value| sign_request = IdentitySignRequest.new subjectIdentity: value, identitySetNodes: nodes }
            .flat_map {|sign_request| @pipe.send_and_expect sign_request, SignedIdentity }
    end
  end

  def sign_scope scope
    scope.flat_map {|value| @pipe.send_and_expect value, SignedScope }
  end
end
