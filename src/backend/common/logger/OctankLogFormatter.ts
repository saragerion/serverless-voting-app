import { LogFormatter } from '@aws-lambda-powertools/logger';
import { UnformattedAttributes, LogAttributes } from '@aws-lambda-powertools/logger/lib/types';

class OctankLogFormatter extends LogFormatter {

  public formatAttributes(attributes: UnformattedAttributes): LogAttributes {
    return {
      message: attributes.message,
      service: attributes.serviceName,
      environment: attributes.environment,
      awsRegion: attributes.awsRegion,
      correlationIds: {
        awsRequestId: attributes.lambdaContext?.awsRequestId,
        xRayTraceId: attributes.xRayTraceId
      },
      lambdaFunction: {
        name: attributes.lambdaContext?.functionName,
        arn: attributes.lambdaContext?.invokedFunctionArn,
        memoryLimitInMB: attributes.lambdaContext?.memoryLimitInMB,
        version: attributes.lambdaContext?.functionVersion,
        coldStart: attributes.lambdaContext?.coldStart,
      },
      logLevel: attributes.logLevel,
      timestamp: this.formatTimestamp(attributes.timestamp),
      logger: {
        sampleRateValue: attributes.sampleRateValue,
      },
    };
  }
}

export {
  OctankLogFormatter
};
